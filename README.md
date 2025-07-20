# Nacha Web

Nacha Web is a Ruby on Rails application designed to provide a comprehensive web interface and RESTful API for parsing, creating, editing, and managing ACH (Automated Clearing House) files.

This project is guided by the requirements in [docs/PRD.md](docs/PRD.md) and the coding conventions in [CONVENTIONS.md](CONVENTIONS.md).

## System Requirements

*   **Ruby:** See `.ruby-version`
*   **Database:** PostgreSQL
*   **Other Dependencies:** See `Gemfile`

## Getting Started

1.  **Install Dependencies:**
    ```bash
    bundle install
    ```

2.  **Set up the Database:**
    ```bash
    bin/rails db:setup
    ```

## Development

This section outlines the common commands needed for local development.

### Running the Application

To run the local web server along with all necessary background jobs (like the Tailwind CSS watcher), use the `dev` script:

```bash
bin/dev
```

### Running Tests

This project uses RSpec for testing. To run the full test suite:

```bash
bin/rspec
```

### Running Linters and Security Scans

To ensure code quality and security, run the following commands. These are also executed as part of the CI pipeline.

*   **RuboCop (Code Style):**
    ```bash
    bin/rubocop
    ```

*   **Brakeman (Security Scan):**
    ```bash
    bin/brakeman
    ```