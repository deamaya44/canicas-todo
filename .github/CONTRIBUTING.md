# Contributing to 3D Task Manager

Thank you for your interest in contributing! 🎉

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/REPO_NAME.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test locally with Docker: `docker-compose up`
6. Commit: `git commit -m "feat: your feature description"`
7. Push: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for local development without Docker)
- AWS CLI (for infrastructure deployment)
- Terraform 1.0+ (for infrastructure changes)

### Local Development
```bash
# Start all services
docker-compose up

# Frontend: http://localhost:3000
# Backend: http://localhost:3001
# DynamoDB Local: http://localhost:8000
```

## Code Style

- Use meaningful variable names
- Add comments for complex logic
- Follow existing code patterns
- Keep functions small and focused

## Commit Messages

Follow conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

## Pull Request Process

1. Update documentation if needed
2. Test your changes locally
3. Ensure no sensitive data is committed
4. Reference any related issues
5. Wait for review and address feedback

## Questions?

Open an issue for discussion before starting major changes.
