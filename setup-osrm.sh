#!/bin/bash
# =============================================================================
# OSRM Map Data Setup Script
# =============================================================================
# Description: Interactive script to download and process OpenStreetMap data
#              for OSRM (Open Source Routing Machine) routing services
# Author: OSRM Map Setup Contributors
# License: MIT
# Repository: https://github.com/mahdialavitabar/osrm-map-data-setup
# =============================================================================

set -e  # Exit on error

# Script configuration
SCRIPT_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Environment variables with defaults (can be overridden)
OSRM_DIR="${OSRM_DIR:-$SCRIPT_DIR/osrm}"
MAX_RETRIES="${MAX_RETRIES:-3}"
RETRY_DELAY="${RETRY_DELAY:-5}"
OSRM_PROFILE="${OSRM_PROFILE:-car}"
SKIP_DOWNLOAD="${SKIP_DOWNLOAD:-0}"
SKIP_PROCESSING="${SKIP_PROCESSING:-0}"
SKIP_HEALTH_CHECK="${SKIP_HEALTH_CHECK:-0}"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Country lists by continent
AFRICA_COUNTRIES="algeria angola benin botswana burkina-faso burundi cameroon canary-islands cape-verde central-african-republic chad comores congo-brazzaville congo-democratic-republic djibouti egypt equatorial-guinea eritrea ethiopia gabon gambia ghana guinea guinea-bissau ivory-coast kenya lesotho liberia libya madagascar malawi mali mauritania mauritius morocco mozambique namibia niger nigeria reunion rwanda saint-helena-ascension-and-tristan-da-cunha sao-tome-and-principe senegal seychelles sierra-leone somalia south-africa south-sudan sudan swaziland tanzania togo tunisia uganda zambia zimbabwe"

ASIA_COUNTRIES="afghanistan armenia azerbaijan bangladesh bhutan cambodia china gcc-states india indonesia iran iraq israel-and-palestine japan jordan kazakhstan kyrgyzstan laos lebanon malaysia-singapore-brunei maldives mongolia myanmar nepal north-korea pakistan philippines south-korea sri-lanka syria taiwan tajikistan thailand turkmenistan uzbekistan vietnam yemen"

AUSTRALIA_OCEANIA_COUNTRIES="australia fiji new-caledonia new-zealand papua-new-guinea"

CENTRAL_AMERICA_COUNTRIES="belize cuba guatemala haiti-and-domrep jamaica nicaragua"

EUROPE_COUNTRIES="albania andorra austria azores belarus belgium bosnia-herzegovina bulgaria croatia cyprus czech-republic denmark estonia faroe-islands finland france georgia germany great-britain greece hungary iceland ireland-and-northern-ireland isle-of-man italy kosovo latvia liechtenstein lithuania luxembourg macedonia malta moldova monaco montenegro netherlands norway poland portugal romania serbia slovakia slovenia spain sweden switzerland turkey ukraine"

NORTH_AMERICA_COUNTRIES="canada greenland mexico us us-midwest us-northeast us-pacific us-south us-west"

SOUTH_AMERICA_COUNTRIES="argentina bolivia brazil chile colombia ecuador paraguay peru suriname uruguay venezuela"

# =============================================================================
# Utility Functions
# =============================================================================

get_region_for_country() {
    local country="$1"

    case "$country" in
        africa|antarctica|asia|australia-oceania|central-america|europe|north-america|russia|south-america)
            echo ""
            return
            ;;
    esac

    for c in $AFRICA_COUNTRIES; do
        if [ "$c" = "$country" ]; then echo "africa"; return; fi
    done

    for c in $ASIA_COUNTRIES; do
        if [ "$c" = "$country" ]; then echo "asia"; return; fi
    done

    for c in $AUSTRALIA_OCEANIA_COUNTRIES; do
        if [ "$c" = "$country" ]; then echo "australia-oceania"; return; fi
    done

    for c in $CENTRAL_AMERICA_COUNTRIES; do
        if [ "$c" = "$country" ]; then echo "central-america"; return; fi
    done

    for c in $EUROPE_COUNTRIES; do
        if [ "$c" = "$country" ]; then echo "europe"; return; fi
    done

    for c in $NORTH_AMERICA_COUNTRIES; do
        if [ "$c" = "$country" ]; then echo "north-america"; return; fi
    done

    for c in $SOUTH_AMERICA_COUNTRIES; do
        if [ "$c" = "$country" ]; then echo "south-america"; return; fi
    done

    echo ""
}

get_countries_for_continent() {
    local continent="$1"
    case "$continent" in
        africa) echo "$AFRICA_COUNTRIES" ;;
        asia) echo "$ASIA_COUNTRIES" ;;
        australia-oceania) echo "$AUSTRALIA_OCEANIA_COUNTRIES" ;;
        central-america) echo "$CENTRAL_AMERICA_COUNTRIES" ;;
        europe) echo "$EUROPE_COUNTRIES" ;;
        north-america) echo "$NORTH_AMERICA_COUNTRIES" ;;
        south-america) echo "$SOUTH_AMERICA_COUNTRIES" ;;
        *) echo "" ;;
    esac
}

# =============================================================================
# UI Functions
# =============================================================================

print_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}${BOLD}🗺️  OSRM Map Data Setup Script${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GRAY}Route Optimization Map Downloader & Processor${NC}                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GRAY}Version ${SCRIPT_VERSION}${NC}                                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    print_banner
    echo -e "${WHITE}${BOLD}USAGE${NC}"
    echo -e "  ${CYAN}$0${NC} [OPTIONS] [COUNTRY/REGION...]"
    echo ""
    echo -e "${WHITE}${BOLD}DESCRIPTION${NC}"
    echo -e "  Download and process OpenStreetMap data for OSRM routing service."
    echo -e "  Run without arguments for interactive menu."
    echo ""
    echo -e "${WHITE}${BOLD}OPTIONS${NC}"
    echo -e "  ${YELLOW}-h, --help${NC}              Show this help message"
    echo -e "  ${YELLOW}-v, --version${NC}           Show version information"
    echo -e "  ${YELLOW}-d, --dir DIR${NC}           Set OSRM output directory (default: ./osrm)"
    echo -e "  ${YELLOW}--skip-download${NC}         Skip download phase (use existing .osm.pbf files)"
    echo -e "  ${YELLOW}--skip-processing${NC}       Skip OSRM processing phase"
    echo -e "  ${YELLOW}--skip-health-check${NC}     Skip health check verification"
    echo -e "  ${YELLOW}--profile PROFILE${NC}       Set OSRM profile (default: car)"
    echo ""
    echo -e "${WHITE}${BOLD}EXAMPLES${NC}"
    echo -e "  ${GRAY}# Interactive mode${NC}"
    echo -e "  ${CYAN}$0${NC}"
    echo ""
    echo -e "  ${GRAY}# Single country${NC}"
    echo -e "  ${CYAN}$0 germany${NC}"
    echo ""
    echo -e "  ${GRAY}# Multiple countries${NC}"
    echo -e "  ${CYAN}$0 france spain italy${NC}"
    echo ""
    echo -e "  ${GRAY}# Entire continent${NC}"
    echo -e "  ${CYAN}$0 europe${NC}"
    echo ""
    echo -e "  ${GRAY}# Custom directory${NC}"
    echo -e "  ${CYAN}$0 --dir /mnt/data/osrm iran${NC}"
    echo ""
    echo -e "  ${GRAY}# Skip download (reprocess existing data)${NC}"
    echo -e "  ${CYAN}$0 --skip-download germany${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}SUPPORTED REGIONS${NC}"
    echo -e "  ${CYAN}Continents:${NC} africa, antarctica, asia, australia-oceania, central-america,"
    echo -e "              europe, north-america, russia, south-america"
    echo ""
    echo -e "  ${CYAN}Countries:${NC} 180+ countries (use interactive mode to browse)"
    echo ""
    echo -e "${WHITE}${BOLD}ENVIRONMENT VARIABLES${NC}"
    echo -e "  ${YELLOW}OSRM_DIR${NC}            Output directory for OSRM files"
    echo -e "  ${YELLOW}MAX_RETRIES${NC}         Download retry attempts (default: 3)"
    echo -e "  ${YELLOW}RETRY_DELAY${NC}         Initial retry delay in seconds (default: 5)"
    echo -e "  ${YELLOW}OSRM_PROFILE${NC}        Routing profile: car, bicycle, foot (default: car)"
    echo ""
    echo -e "${WHITE}${BOLD}MORE INFO${NC}"
    echo -e "  Repository: ${CYAN}https://github.com/mahdialavitabar/osrm-map-data-setup${NC}"
    echo -e "  OSRM Docs:  ${CYAN}http://project-osrm.org/docs/${NC}"
    echo ""
}

print_section_header() {
    local title="$1"
    local icon="$2"
    echo ""
    echo -e "${BLUE}┌──────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${icon} ${BOLD}${WHITE}${title}${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────────────────────┘${NC}"
}

print_continent_menu() {
    print_section_header "Select a Continent" "🌍"
    echo ""
    echo -e "  ${YELLOW}[1]${NC}  🌍  ${WHITE}Africa${NC}              ${GRAY}(58 countries)${NC}"
    echo -e "  ${YELLOW}[2]${NC}  🧊  ${WHITE}Antarctica${NC}          ${GRAY}(whole continent)${NC}"
    echo -e "  ${YELLOW}[3]${NC}  🌏  ${WHITE}Asia${NC}                ${GRAY}(37 countries)${NC}"
    echo -e "  ${YELLOW}[4]${NC}  🦘  ${WHITE}Australia & Oceania${NC} ${GRAY}(5 countries)${NC}"
    echo -e "  ${YELLOW}[5]${NC}  🌴  ${WHITE}Central America${NC}     ${GRAY}(6 countries)${NC}"
    echo -e "  ${YELLOW}[6]${NC}  🏰  ${WHITE}Europe${NC}              ${GRAY}(49 countries)${NC}"
    echo -e "  ${YELLOW}[7]${NC}  🗽  ${WHITE}North America${NC}       ${GRAY}(9 regions)${NC}"
    echo -e "  ${YELLOW}[8]${NC}  🐻  ${WHITE}Russia${NC}              ${GRAY}(whole country)${NC}"
    echo -e "  ${YELLOW}[9]${NC}  🌎  ${WHITE}South America${NC}       ${GRAY}(11 countries)${NC}"
    echo ""
    echo -e "  ${YELLOW}[0]${NC}  📝  ${WHITE}Enter custom region/country${NC}"
    echo -e "  ${YELLOW}[q]${NC}  ❌  ${WHITE}Quit${NC}"
    echo ""
}

print_countries_for_continent() {
    local continent="$1"
    local countries_str=$(get_countries_for_continent "$continent")
    local sorted_countries=$(echo "$countries_str" | tr ' ' '\n' | sort | tr '\n' ' ')

    local continent_display=$(echo "$continent" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    print_section_header "Countries in ${continent_display}" "📍"
    echo ""

    local col=0
    local max_cols=3
    local count=1

    for country in $sorted_countries; do
        local display_name=$(echo "$country" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        printf "  ${YELLOW}[%2d]${NC} %-28s" "$count" "$display_name"
        col=$((col + 1))
        if [ $col -eq $max_cols ]; then
            echo ""
            col=0
        fi
        count=$((count + 1))
    done

    if [ $col -ne 0 ]; then
        echo ""
    fi

    echo ""
    echo -e "  ${YELLOW}[a]${NC}   ${CYAN}Download entire ${continent_display}${NC}"
    echo -e "  ${YELLOW}[b]${NC}   ${WHITE}Back to continents${NC}"
    echo -e "  ${YELLOW}[q]${NC}   ${WHITE}Quit${NC}"
    echo ""
}

get_country_by_index() {
    local continent="$1"
    local index="$2"
    local countries_str=$(get_countries_for_continent "$continent")
    local sorted_countries=$(echo "$countries_str" | tr ' ' '\n' | sort)
    echo "$sorted_countries" | sed -n "${index}p"
}

get_country_count() {
    local continent="$1"
    local countries_str=$(get_countries_for_continent "$continent")
    echo "$countries_str" | wc -w | tr -d ' '
}

ask_proceed_or_continue() {
    echo ""
    echo -n -e "${GREEN}?${NC} Download now? [Y]es / [n]o, add more: "
    read proceed_choice
    if [ "$proceed_choice" = "n" ] || [ "$proceed_choice" = "N" ]; then
        return 1
    fi
    return 0
}

# =============================================================================
# Interactive Menu
# =============================================================================

interactive_menu() {
    SELECTED_ITEMS=""

    while true; do
        print_banner

        if [ -n "$(echo $SELECTED_ITEMS | tr -d ' ')" ]; then
            echo -e "${GREEN}📦 Selected:${NC}${WHITE}$SELECTED_ITEMS${NC}"
            echo ""
        fi

        print_continent_menu

        echo -n -e "${GREEN}?${NC} Select continent [1-9, 0, q]: "
        read choice

        case $choice in
            1) continent="africa" ;;
            2)
                SELECTED_ITEMS="$SELECTED_ITEMS antarctica"
                echo -e "\n${GREEN}✓${NC} Added: Antarctica"
                ask_proceed_or_continue
                if [ $? -eq 0 ]; then return 0; fi
                continue
                ;;
            3) continent="asia" ;;
            4) continent="australia-oceania" ;;
            5) continent="central-america" ;;
            6) continent="europe" ;;
            7) continent="north-america" ;;
            8)
                SELECTED_ITEMS="$SELECTED_ITEMS russia"
                echo -e "\n${GREEN}✓${NC} Added: Russia"
                ask_proceed_or_continue
                if [ $? -eq 0 ]; then return 0; fi
                continue
                ;;
            9) continent="south-america" ;;
            0)
                echo ""
                echo -e "${CYAN}Enter custom region/country (e.g., 'iran' or 'europe/monaco'):${NC}"
                echo -n "   Custom input: "
                read custom_input
                if [ -n "$custom_input" ]; then
                    SELECTED_ITEMS="$SELECTED_ITEMS $custom_input"
                    echo -e "${GREEN}✓${NC} Added: $custom_input"
                    ask_proceed_or_continue
                    if [ $? -eq 0 ]; then return 0; fi
                fi
                continue
                ;;
            q|Q)
                if [ -n "$(echo $SELECTED_ITEMS | tr -d ' ')" ]; then
                    return 0
                else
                    echo -e "\n${YELLOW}No countries selected. Exiting.${NC}"
                    exit 0
                fi
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 1
                continue
                ;;
        esac

        while true; do
            print_banner

            if [ -n "$(echo $SELECTED_ITEMS | tr -d ' ')" ]; then
                echo -e "${GREEN}📦 Selected:${NC}${WHITE}$SELECTED_ITEMS${NC}"
                echo ""
            fi

            print_countries_for_continent "$continent"

            local max_count=$(get_country_count "$continent")

            echo ""
            echo -n -e "${GREEN}?${NC} Select country number, [a]ll, [b]ack, or [q]uit: "
            read country_choice

            case $country_choice in
                a|A)
                    SELECTED_ITEMS="$SELECTED_ITEMS $continent"
                    echo -e "\n${GREEN}✓${NC} Added entire continent: $continent"
                    ask_proceed_or_continue
                    if [ $? -eq 0 ]; then return 0; fi
                    break
                    ;;
                b|B)
                    break
                    ;;
                q|Q)
                    if [ -n "$(echo $SELECTED_ITEMS | tr -d ' ')" ]; then
                        return 0
                    else
                        echo -e "\n${YELLOW}No countries selected. Exiting.${NC}"
                        exit 0
                    fi
                    ;;
                *[0-9]*)
                    if [ "$country_choice" -ge 1 ] 2>/dev/null && [ "$country_choice" -le "$max_count" ] 2>/dev/null; then
                        selected_country=$(get_country_by_index "$continent" "$country_choice")
                        SELECTED_ITEMS="$SELECTED_ITEMS $selected_country"
                        echo -e "\n${GREEN}✓${NC} Added: $selected_country"

                        ask_proceed_or_continue
                        if [ $? -eq 0 ]; then return 0; fi
                    else
                        echo -e "${RED}Invalid number. Please try again.${NC}"
                        sleep 1
                    fi
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Please try again.${NC}"
                    sleep 1
                    ;;
            esac
        done
    done
}

print_selection_summary() {
    print_section_header "Download Summary" "📋"
    echo ""

    for item in $SELECTED_ITEMS; do
        local display_name=$(echo "$item" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        echo -e "  ${GREEN}●${NC} ${WHITE}$display_name${NC}"
    done

    echo ""
}

prompt_for_countries() {
    interactive_menu

    if [ -z "$(echo $SELECTED_ITEMS | tr -d ' ')" ]; then
        echo -e "${RED}❌ No countries specified. Exiting.${NC}"
        exit 1
    fi

    print_banner
    print_selection_summary

    echo -e "${CYAN}Starting download process...${NC}"
    echo ""
}

# =============================================================================
# Core Functions
# =============================================================================

check_dependencies() {
    local missing_deps=()

    # Check for Docker only if we need processing
    if [ "$SKIP_PROCESSING" -eq 0 ]; then
        if ! command -v docker > /dev/null 2>&1; then
            missing_deps+=("docker")
        fi
    fi

    # Check for download tools only if we need download
    if [ "$SKIP_DOWNLOAD" -eq 0 ]; then
        if ! command -v curl > /dev/null 2>&1 && ! command -v wget > /dev/null 2>&1; then
            missing_deps+=("curl or wget")
        fi
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required dependencies:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "   ${YELLOW}●${NC} $dep"
        done
        echo ""
        echo -e "${CYAN}Installation help:${NC}"
        echo -e "  ${GRAY}Docker:${NC} https://docs.docker.com/get-docker/"
        echo -e "  ${GRAY}curl:${NC}   brew install curl (macOS) / apt install curl (Ubuntu)"
        echo ""
        return 1
    fi

    # Check Docker daemon only if we need processing
    if [ "$SKIP_PROCESSING" -eq 0 ]; then
        if ! docker info > /dev/null 2>&1; then
            echo -e "${RED}❌ Docker daemon is not running${NC}"
            echo -e "${CYAN}Please start Docker Desktop or Docker daemon${NC}"
            return 1
        fi
    fi

    return 0
}

get_download_url() {
    local country="$1"
    local country_lower=$(echo "$country" | tr '[:upper:]' '[:lower:]')
    local region=$(get_region_for_country "$country_lower")

    if [ -z "$region" ]; then
        echo "https://download.geofabrik.de/$country_lower-latest.osm.pbf"
    elif echo "$country_lower" | grep -q "/"; then
        echo "https://download.geofabrik.de/$country_lower-latest.osm.pbf"
    else
        echo "https://download.geofabrik.de/$region/$country_lower-latest.osm.pbf"
    fi
}

download_with_retry() {
    local url="$1"
    local output_file="$2"
    local country="$3"
    local attempt=1
    local current_delay=$RETRY_DELAY

    # Ensure parent directory exists
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"

    while [ $attempt -le $MAX_RETRIES ]; do
        echo -e "${CYAN}📥 Attempt $attempt/$MAX_RETRIES:${NC} Downloading ${WHITE}$country${NC}..."
        echo -e "   ${GRAY}URL: $url${NC}"
        echo ""

        if command -v curl > /dev/null 2>&1; then
            if curl -L --fail --progress-bar --retry 3 --retry-delay 2 -C - -o "$output_file" "$url" 2>&1; then
                if [ -f "$output_file" ] && [ -s "$output_file" ]; then
                    local file_size=$(du -h "$output_file" | cut -f1)
                    echo -e "\n${GREEN}✅ Download successful!${NC} File size: ${WHITE}$file_size${NC}"
                    return 0
                fi
            fi
        elif command -v wget > /dev/null 2>&1; then
            if wget --show-progress -c -O "$output_file" "$url" 2>&1; then
                if [ -f "$output_file" ] && [ -s "$output_file" ]; then
                    local file_size=$(du -h "$output_file" | cut -f1)
                    echo -e "\n${GREEN}✅ Download successful!${NC} File size: ${WHITE}$file_size${NC}"
                    return 0
                fi
            fi
        else
            echo -e "${RED}❌ Error: Please install curl or wget${NC}"
            exit 1
        fi

        echo -e "${YELLOW}⚠️  Download attempt $attempt failed.${NC}"

        if [ $attempt -lt $MAX_RETRIES ]; then
            echo -e "${CYAN}⏳ Retrying in $current_delay seconds...${NC}"
            sleep $current_delay
            current_delay=$((current_delay * 2))
        fi

        attempt=$((attempt + 1))
    done

    echo -e "${RED}❌ Failed to download $country after $MAX_RETRIES attempts.${NC}"
    return 1
}

process_map() {
    local map_name="$1"
    local profile_lua="/opt/${OSRM_PROFILE}.lua"

    print_section_header "Processing $map_name with OSRM" "⚙️"
    echo -e "   ${GRAY}Profile: ${OSRM_PROFILE}${NC}"
    echo ""

    # Pull OSRM Docker image if not present
    if ! docker image inspect osrm/osrm-backend > /dev/null 2>&1; then
        echo -e "${CYAN}📦 Pulling OSRM Docker image...${NC}"
        if ! docker pull osrm/osrm-backend; then
            echo -e "${RED}❌ Failed to pull OSRM Docker image${NC}"
            return 1
        fi
        echo ""
    fi

    echo -e "${CYAN}📊 Step 1/3:${NC} Extracting road network..."
    echo -e "   ${GRAY}This may take several minutes for large regions...${NC}"
    if ! docker run --rm -v "$OSRM_DIR:/data" osrm/osrm-backend osrm-extract -p "$profile_lua" /data/$map_name.osm.pbf; then
        echo -e "${RED}❌ Extract failed for $map_name${NC}"
        echo -e "${YELLOW}💡 Tip: Check if the .osm.pbf file is corrupted or incomplete${NC}"
        return 1
    fi
    echo -e "${GREEN}✓${NC} Extraction complete"

    echo ""
    echo -e "${CYAN}📊 Step 2/3:${NC} Partitioning graph..."
    echo -e "   ${GRAY}Optimizing routing performance...${NC}"
    if ! docker run --rm -v "$OSRM_DIR:/data" osrm/osrm-backend osrm-partition /data/$map_name.osrm; then
        echo -e "${RED}❌ Partition failed for $map_name${NC}"
        return 1
    fi
    echo -e "${GREEN}✓${NC} Partitioning complete"

    echo ""
    echo -e "${CYAN}📊 Step 3/3:${NC} Customizing graph..."
    echo -e "   ${GRAY}Applying ${OSRM_PROFILE} profile optimizations...${NC}"
    if ! docker run --rm -v "$OSRM_DIR:/data" osrm/osrm-backend osrm-customize /data/$map_name.osrm; then
        echo -e "${RED}❌ Customize failed for $map_name${NC}"
        return 1
    fi
    echo -e "${GREEN}✓${NC} Customization complete"

    echo ""
    echo -e "${GREEN}✅ Processing complete for ${WHITE}$map_name${NC}"
    return 0
}

rename_to_default() {
    local map_name="$1"

    echo ""
    echo -e "${CYAN}📝 Renaming $map_name files to map.osrm for docker-compose...${NC}"

    cd "$OSRM_DIR"

    for ext in osrm osrm.cell_metrics osrm.cells osrm.cnbg osrm.cnbg_to_ebg osrm.datasource_names osrm.ebg osrm.ebg_nodes osrm.edges osrm.enw osrm.fileIndex osrm.geometry osrm.icd osrm.maneuver_overrides osrm.mldgr osrm.names osrm.nbg_nodes osrm.partition osrm.properties osrm.ramIndex osrm.timestamp osrm.tld osrm.tls osrm.turn_duration_penalties osrm.turn_penalties_index osrm.turn_weight_penalties; do
        if [ -f "$map_name.$ext" ]; then
            mv "$map_name.$ext" "map.$ext" 2>/dev/null || true
        fi
    done

    echo -e "${GREEN}✅ Files renamed successfully${NC}"
}

verify_osrm_files() {
    print_section_header "Verifying OSRM Files" "🔍"
    echo ""

    local all_good=true

    for file in map.osrm map.osrm.cell_metrics map.osrm.cells map.osrm.cnbg map.osrm.datasource_names map.osrm.ebg map.osrm.edges map.osrm.geometry map.osrm.mldgr map.osrm.names map.osrm.partition map.osrm.properties map.osrm.timestamp; do
        if [ -f "$OSRM_DIR/$file" ]; then
            local size=$(du -h "$OSRM_DIR/$file" | cut -f1)
            echo -e "  ${GREEN}✅${NC} $file ${GRAY}($size)${NC}"
        else
            echo -e "  ${RED}❌${NC} $file ${RED}- MISSING${NC}"
            all_good=false
        fi
    done

    echo ""

    if $all_good; then
        echo -e "${GREEN}✅ All required OSRM files are present!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some required files are missing${NC}"
        return 1
    fi
}

health_check() {
    print_section_header "OSRM Health Check" "🏥"

    if ! verify_osrm_files; then
        echo ""
        echo -e "${RED}❌ Health check failed: Missing required files${NC}"
        return 1
    fi

    echo ""
    echo -e "${CYAN}🚀 Starting temporary OSRM container for route test...${NC}"

    local container_id=$(docker run -d --rm -p 5001:5000 -v "$OSRM_DIR:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/map.osrm 2>/dev/null)

    if [ -z "$container_id" ]; then
        echo -e "${YELLOW}⚠️  Could not start test container (this may be okay if OSRM is already running)${NC}"
        echo -e "${GREEN}✅ File verification passed - OSRM setup appears complete${NC}"
        return 0
    fi

    echo -e "${CYAN}⏳ Waiting for OSRM to start (10 seconds)...${NC}"
    sleep 10

    echo -e "${CYAN}🔍 Testing route calculation...${NC}"
    local test_response=$(curl -s "http://localhost:5001/route/v1/driving/51.42,35.69;51.43,35.70?overview=false" 2>/dev/null || echo "")

    docker stop "$container_id" > /dev/null 2>&1 || true

    if echo "$test_response" | grep -q '"code":"Ok"'; then
        echo -e "${GREEN}✅ OSRM routing test passed!${NC}"
        echo ""
        echo -e "${GREEN}🎉 Health check complete - OSRM is ready to use!${NC}"
        return 0
    elif echo "$test_response" | grep -q '"code"'; then
        echo -e "${YELLOW}⚠️  OSRM responded but routing may have issues (test coordinates might be outside map area)${NC}"
        echo -e "${GREEN}✅ OSRM server is functional - setup complete${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Could not verify OSRM routing (server may need more time or test coords outside map)${NC}"
        echo -e "${GREEN}✅ File verification passed - manual testing recommended${NC}"
        return 0
    fi
}

download_countries_async() {
    local download_dir="$OSRM_DIR/downloads"
    mkdir -p "$download_dir"

    print_section_header "Async Downloads" "🚀"
    echo ""

    local count=0
    for country in $SELECTED_ITEMS; do
        count=$((count + 1))
    done

    echo -e "${WHITE}Starting downloads for ${CYAN}${count}${WHITE} item(s)...${NC}"
    echo ""

    local pids=""
    for country in $SELECTED_ITEMS; do
        local country_lower=$(echo "$country" | tr '[:upper:]' '[:lower:]')
        local url=$(get_download_url "$country_lower")
        local output_file="$download_dir/$country_lower.osm.pbf"
        local log_file="$download_dir/$country_lower.log"

        echo -e "  ${CYAN}📦${NC} Queuing: ${WHITE}$country_lower${NC}"

        (
            download_with_retry "$url" "$output_file" "$country_lower" > "$log_file" 2>&1
            echo $? > "$download_dir/$country_lower.status"
        ) &

        pids="$pids $!"
    done

    echo ""
    echo -e "${CYAN}⏳ Waiting for downloads to complete...${NC}"
    echo -e "   ${GRAY}(Check progress in $download_dir/*.log)${NC}"
    echo ""

    local all_success=true
    local successful_country=""

    for pid in $pids; do
        wait $pid
    done

    for country in $SELECTED_ITEMS; do
        local country_lower=$(echo "$country" | tr '[:upper:]' '[:lower:]')

        if [ -f "$download_dir/$country_lower.status" ]; then
            local status=$(cat "$download_dir/$country_lower.status")
            if [ "$status" -eq 0 ]; then
                echo -e "  ${GREEN}✅${NC} $country_lower: Download complete"
                if [ -z "$successful_country" ]; then
                    successful_country="$country_lower"
                fi
            else
                echo -e "  ${RED}❌${NC} $country_lower: Download failed ${GRAY}(check $download_dir/$country_lower.log)${NC}"
                all_success=false
            fi
            rm -f "$download_dir/$country_lower.status"
        fi
    done

    echo ""

    if ! $all_success; then
        echo -e "${YELLOW}⚠️  Some downloads failed. Check logs for details.${NC}"
        echo ""
    fi

    FIRST_SUCCESSFUL="$successful_country"
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "OSRM Map Setup Script v${SCRIPT_VERSION}"
                exit 0
                ;;
            -d|--dir)
                OSRM_DIR="$2"
                shift 2
                ;;
            --skip-download)
                SKIP_DOWNLOAD=1
                shift
                ;;
            --skip-processing)
                SKIP_PROCESSING=1
                shift
                ;;
            --skip-health-check)
                SKIP_HEALTH_CHECK=1
                shift
                ;;
            --profile)
                OSRM_PROFILE="$2"
                shift 2
                ;;
            -*)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                echo -e "Run '$0 --help' for usage information"
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    print_banner

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

    mkdir -p "$OSRM_DIR"

    if [ "$#" -ge 1 ]; then
        SELECTED_ITEMS="$*"
        print_selection_summary
    else
        prompt_for_countries
    fi

    local count=0
    for item in $SELECTED_ITEMS; do
        count=$((count + 1))
    done

    if [ $count -eq 1 ]; then
        local country=$(echo $SELECTED_ITEMS | tr -d ' ')
        local country_lower=$(echo "$country" | tr '[:upper:]' '[:lower:]')
        local url=$(get_download_url "$country_lower")
        local pbf_file="$OSRM_DIR/$country_lower.osm.pbf"

        if [ "$SKIP_DOWNLOAD" -eq 0 ]; then
            print_section_header "Downloading: $country_lower" "📥"

            if ! download_with_retry "$url" "$pbf_file" "$country_lower"; then
                echo ""
                echo -e "${RED}❌ Failed to download $country_lower. Please check your internet connection.${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}⏭️  Skipping download (using existing file)${NC}"
            if [ ! -f "$pbf_file" ]; then
                echo -e "${RED}❌ Error: $pbf_file not found${NC}"
                exit 1
            fi
        fi

        if [ "$SKIP_PROCESSING" -eq 0 ]; then
            if ! process_map "$country_lower"; then
                echo ""
                echo -e "${RED}❌ Failed to process $country_lower map.${NC}"
                exit 1
            fi

            rename_to_default "$country_lower"
        else
            echo -e "${YELLOW}⏭️  Skipping OSRM processing${NC}"
        fi

    else
        download_countries_async

        if [ -n "$FIRST_SUCCESSFUL" ]; then
            local pbf_file="$OSRM_DIR/downloads/$FIRST_SUCCESSFUL.osm.pbf"
            mv "$pbf_file" "$OSRM_DIR/$FIRST_SUCCESSFUL.osm.pbf"

            if [ "$SKIP_PROCESSING" -eq 0 ]; then
                if ! process_map "$FIRST_SUCCESSFUL"; then
                    echo ""
                    echo -e "${RED}❌ Failed to process $FIRST_SUCCESSFUL map.${NC}"
                    exit 1
                fi

                rename_to_default "$FIRST_SUCCESSFUL"
            fi

            echo ""
            echo -e "${YELLOW}💡 Note:${NC} Only the first successful download (${WHITE}$FIRST_SUCCESSFUL${NC}) was processed."
            echo -e "   Other downloaded maps are in: ${CYAN}$OSRM_DIR/downloads/${NC}"
            echo -e "   To process another map, run: ${WHITE}$0 <country_name>${NC}"
        else
            echo ""
            echo -e "${RED}❌ No maps were downloaded successfully.${NC}"
            exit 1
        fi
    fi

    if [ "$SKIP_HEALTH_CHECK" -eq 0 ] && [ "$SKIP_PROCESSING" -eq 0 ]; then
        health_check
    else
        echo -e "${YELLOW}⏭️  Skipping health check${NC}"
    fi

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}   ${WHITE}${BOLD}🎉 OSRM Setup Complete!${NC}                                                 ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}📁${NC} Map files location: ${WHITE}$OSRM_DIR${NC}"
    echo -e "  ${CYAN}🎯${NC} Profile used: ${WHITE}$OSRM_PROFILE${NC}"
    echo ""
    echo -e "  ${CYAN}🚀${NC} Start OSRM with Docker:"
    echo -e "     ${WHITE}docker run -t -i -p 5000:5000 -v \"\$PWD/osrm:/data\" \\${NC}"
    echo -e "     ${WHITE}  osrm/osrm-backend osrm-routed --algorithm mld /data/map.osrm${NC}"
    echo ""
    echo -e "  ${CYAN}🐳${NC} Or use Docker Compose (see examples/docker-compose.yml):"
    echo -e "     ${WHITE}docker-compose up -d${NC}"
    echo ""
    echo -e "  ${CYAN}🧪${NC} Test routing API:"
    echo -e "     ${WHITE}curl 'http://localhost:5000/route/v1/driving/LON1,LAT1;LON2,LAT2?overview=false'${NC}"
    echo -e "     ${GRAY}(Replace LON,LAT with coordinates from your region)${NC}"
    echo ""
    echo -e "  ${CYAN}📖${NC} API Documentation: ${WHITE}http://project-osrm.org/docs/v5.24.0/api/${NC}"
    echo -e "  ${CYAN}💡${NC} More examples: ${WHITE}$SCRIPT_DIR/examples/api-usage.md${NC}"
    echo ""
}

main "$@"
