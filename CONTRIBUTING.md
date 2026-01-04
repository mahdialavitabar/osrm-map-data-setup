# Contributing to OSRM Map Setup

Thank you for considering contributing to OSRM Map Setup! 🎉

## 🌟 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, Bash version, Docker version)
- **Relevant logs** or error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear, descriptive title**
- **Provide detailed description** of the proposed functionality
- **Explain why this enhancement would be useful** to most users
- **List similar implementations** in other projects if applicable

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes** with clear, descriptive commits
4. **Test thoroughly** on multiple platforms if possible
5. **Update documentation** as needed
6. **Submit a pull request**

## 📋 Development Guidelines

### Code Style

- Use **4 spaces** for indentation (no tabs)
- Follow **bash best practices**:
  - Quote variables: `"$variable"`
  - Use `[[ ]]` instead of `[ ]` for tests
  - Use `$(command)` instead of backticks
  - Add `set -e` for error handling
- Keep functions **small and focused**
- Add **comments** for complex logic
- Use **meaningful variable names**

### Commit Messages

Follow conventional commits:

```
type(scope): subject

body

footer
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**

```
feat(download): add support for multiple simultaneous downloads

fix(health-check): resolve timeout issue on slow networks

docs(readme): add troubleshooting section for Docker issues
```

### Testing Checklist

Before submitting a PR, ensure:

- [ ] Script runs without errors on bash 5.0+
- [ ] Interactive menu displays correctly
- [ ] Command-line arguments work as expected
- [ ] Download retry logic functions properly
- [ ] OSRM processing completes successfully
- [ ] Health check validates correctly
- [ ] Error messages are clear and helpful
- [ ] Code is well-commented
- [ ] Documentation is updated

### Platform Testing

Please test on:

- macOS (10.15+)
- Ubuntu (20.04+)
- Debian (10+)
- Other Linux distributions (when possible)

## 🏗️ Project Structure

```
osrm-map-data-setup/
├── setup-osrm.sh          # Main script
├── README.md              # User documentation
├── CONTRIBUTING.md        # This file
├── LICENSE                # MIT License
├── .gitignore            # Git ignore patterns
└── examples/
    ├── docker-compose.yml # Docker Compose example
    └── api-usage.md      # API usage examples
```

## 🎯 Priority Areas

We especially welcome contributions in:

- **Platform compatibility** - Windows WSL, additional Linux distros
- **Error handling** - Better error messages and recovery
- **Performance** - Optimization for large datasets
- **Features** - Additional OSRM profiles (bicycle, foot, etc.)
- **Documentation** - Tutorials, examples, translations
- **Testing** - Automated testing framework
- **CI/CD** - GitHub Actions workflows

## 💬 Communication

- **Questions?** Open a GitHub Discussion
- **Bug reports?** Create an Issue
- **Feature ideas?** Start a Discussion or create an Issue
- **Security concerns?** See SECURITY.md (email maintainers privately)

## 🎨 Adding New Features

When adding new features:

1. **Discuss first** - Open an issue to discuss the feature
2. **Keep it simple** - Maintain the script's ease of use
3. **Backward compatible** - Don't break existing functionality
4. **Document thoroughly** - Update README and add examples
5. **Test extensively** - Ensure it works across platforms

## 🐛 Debugging Tips

```bash
# Enable bash debugging
bash -x ./setup-osrm.sh

# Check specific function
bash -c 'source ./setup-osrm.sh; get_download_url iran'

# Verbose Docker output
docker run -v "$PWD/osrm:/data" osrm/osrm-backend osrm-extract -p /opt/car.lua /data/iran.osm.pbf
```

## 📝 Documentation

When updating documentation:

- Use **clear, concise language**
- Include **examples** for complex topics
- Add **screenshots** for UI changes
- Test all **code snippets** and commands
- Keep **table of contents** updated
- Maintain **consistent formatting**

## 🙏 Recognition

All contributors will be recognized in:

- GitHub Contributors page
- Special thanks in release notes
- README acknowledgments (for major contributions)

## 📜 Code of Conduct

- Be **respectful** and **inclusive**
- Provide **constructive feedback**
- Focus on **what is best** for the community
- Show **empathy** towards other community members

Thank you for contributing! 🚀
