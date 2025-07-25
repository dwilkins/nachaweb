# Product Requirements Document: Nacha Web

## Implementation Roadmap

This roadmap breaks down the development of the Nacha Web application into
logical phases. The goal is to build the application incrementally, starting
with the core foundation and layering features on top.

When implementing requirements, always create tests for new public methods and classes
Coding conventions for this project are defined in ../CONVENTIONS.md

### Phase 1: Core Application Setup, CI/CD & User Management
*   [X] **1.1.** Initialize the Rails application with PostgreSQL, RSpec, and Tailwind CSS.
*   [X] **1.2.** Set up a robust CI/CD pipeline using GitHub Actions to automatically run tests, `rubocop`, and `brakeman` on every push to the main branch.
*   [X] **1.3.** Set up User Authentication (`bin/rails generate authentication`). and user signup
*   [X] **1.4.** Implement Role-Based Access Control (RBAC) on the `User` model.

### Phase 2: Foundational Models & API
*   [X] **2.1.** Create the `ApiKey` model and a basic web interface for users to manage their keys.
*   [X] **2.2.** Create a sidebar with links to pages the logged in user can navigate to.
*   [X] **2.3.** Create the `AchInputFile` model with all specified attributes.
*   [X] **2.4.** Create the `AchRecord` model with all specified attributes.
*   [X] **2.5.** Create the `AchFile` model with all specified attributes.
*   [X] **2.6.** Build the initial RESTful API endpoints for parsing a single record and a full file (`/api/v1/parse/record`, `/api/v1/parse/file`).
*   [X] **2.7.** Implement API key authentication for the API endpoints.

### Phase 3: Web Interface - Core ACH Processing
*   [X] **3.1.** Implement the web UI for uploading ACH files, pasting text, or providing a URL.
*   [X] **3.2.** Set up Active Storage for file uploads.
*   [X] **3.3.** Create the `AchParsingJob` and integrate it with Solid Queue to handle asynchronous parsing.
*   [ ] **3.4.** Implement Action Cable / Solid Cable to provide real-time notifications to the user about the parsing status.
*   [ ] **3.5.** Implement the temporary file storage logic and the `CleanupTemporaryFilesJob`.

### Phase 4: Advanced Web Features
*   [ ] **4.1.** Implement the JSON to ACH/Markdown conversion feature, including the `JsonToAchJob`.
*   [ ] **4.2.** Build the web interface for creating new ACH files from scratch, using `Nacha.ach_record_types` to dynamically build forms.
*   [ ] **4.3.** Implement the ACH file editing interface.
*   [ ] **4.4.** Integrate the `paper_trail` gem to provide version history for `AchFile` edits.

### Phase 5: API Enhancements & Webhooks
*   [ ] **5.1.** Implement API rate limiting using the `rack-attack` gem.
*   [ ] **5.2.** Create the `WebhookEndpoint` model and the UI for users to manage their webhooks.
*   [ ] **5.3.** Implement the `WebhookDispatchJob` for sending webhook notifications.
*   [ ] **5.4.** Add support for both signed and encrypted webhook payloads.

### Phase 6: Search & Deployment
*   [ ] **6.1.** Integrate Elasticsearch and the `searchkick` gem with the `AchFile` model.
*   [ ] **6.2.** Build the search interface in the web application.
*   [ ] **6.3.** Configure the application for deployment using Kamal and Docker.

---

## 1. Overview

Nacha Web is a Ruby on Rails application designed to provide a comprehensive web interface and RESTful API for parsing, creating, editing, and managing ACH (Automated Clearing House) files. It leverages the `nacha` gem to handle the core ACH logic. The application will serve users who need to work with ACH files, offering them tools to convert between ACH and other formats like JSON, store and search file data, and integrate with their own systems via API and webhooks.

## 2. Core Features

### 2.1. User and Access Management

- [ ] **User Authentication:** Implement a full user authentication system using `bin/rails generate authentication`. Users will sign up and log in with an email address and password.
- [ ] **Role-Based Access Control (RBAC):**
  - [ ] The `User` model will have a `role` attribute (enum) with at least two roles: `user` and `admin`.
  - [ ] `admin` users will have access to administrative dashboards (e.g., viewing all users, system-wide settings).
  - [ ] Authorization logic will be implemented to restrict access to certain features based on user roles.

### 2.2. API Key Management

- [ ] **Functionality:** Authenticated users can create, view, and revoke API keys through the web interface.
- [ ] **Model:** An `ApiKey` model will be associated with a `User`. It will include:
  - [ ] A secure, randomly generated token (`has_secure_token`).
  - [ ] A user-definable description.
  - [ ] Timestamps for creation, last use, and an optional expiration date.
- [ ] **API Authentication:** The RESTful API will use these keys for bearer token authentication.

## 3. Web Interface

### 3.1. ACH File Processing

- [ ] **Upload Methods:** Users can provide ACH data in three ways:
  1.  [ ] File upload (`<input type="file">`).
  2.  [ ] Pasting raw ACH text into a `<textarea>`.
  3.  [ ] Providing a publicly accessible URL to an ACH file.
- [ ] **Parsing:**
  - [ ] Parsing will be handled asynchronously by a `AchParsingJob` using Solid Queue.
  - [ ] Active Storage will be used for handling file uploads.
  - [ ] Upon job completion (success or failure), the user will be notified in real-time via Action Cable / Solid Cable. The UI will update to show the parsed file or an error message.
- [ ] **Output Formats:** The parsed output can be displayed to the user as JSON, a formatted HTML view, or a Markdown block.
- [ ] **Temporary Storage:**
  - [ ] All newly parsed files will be marked for temporary storage.
  - [ ] A background job (`CleanupTemporaryFilesJob`) will run daily to delete temporary files older than 7 days.
  - [ ] Users will have an explicit option in the UI to mark a file for "long-term" storage, which will prevent it from being deleted by the cleanup job.

### 3.2. JSON to ACH/Markdown Conversion

- [ ] **Functionality:** Users can upload a JSON file (or paste JSON text) that represents ACH data and convert it into a valid ACH file or a Markdown representation.
- [ ] **Implementation:** This follows the same asynchronous pattern as ACH parsing, using a `JsonToAchJob`, websockets for notification, and temporary storage rules.
- [ ] **Dependency:** This feature's implementation is contingent on the `nacha` gem supporting the creation of ACH files from a structured hash or JSON object.

### 3.3. Data Storage and Modeling

- [ ] **`AchFile` Model:** This will be the central model for stored files.
  - [ ] `uuid`: A UUID for generating public, non-sequential URLs (`generates_token_for`).
  - [ ] `user_id`: Associates the file with a user.
  - [ ] `filename`: The original name of the uploaded file.
  - [ ] `status`: The current state of the file (e.g., `parsing`, `completed`, `failed`).
  - [ ] `storage_type`: An enum (`temporary`, `permanent`).
  - [ ] `parsed_data`: A `jsonb` column to store the full JSON representation of the parsed ACH file.
  - [ ] `error_message`: To store any errors that occurred during parsing.

- [ ] **`AchInputFile` Model:** This will be a storage mechanism for input files.
  - [ ] `ach_file_id`: The AchFile object that is associated with this AchInputFile
  - [ ] `name`: The filename
  - [ ] `format`: One of ach, json or markdown, signifying the type of data in the input
  - [ ] `modality`: The mechanism by which the data was received.  Either
        "string", "fileupload" or "url"
  - [ ] `source`: The string in the case of string modality, The full filename
        in the case of "fileupload" modality, and the full URL in the case of
        "url" modality
  - [ ] `name`: The filename

- [ ] ** `AchRecord` Model:** This is a single record from an AchInputFile
  - [ ] `ach_file_id`: The AchFile object that is associated with this AchRecord
  - [ ] `ach_record_name`: The name of the ach record.  From Nacha::Record#record_type
  - [ ] `parsed_data`: A `jsonb` column to store the full JSON representation of
        the parsed ACH record.

- [ ] **Database:** PostgreSQL is recommended to take advantage of the `jsonb`
      data type for efficient querying of the `parsed_data` column.

### 3.4. ACH File Editing

- [ ] **Functionality:** Users can edit the contents of their stored ACH files
      via the web interface.
- [ ] **Versioning:**
  - [ ] All changes to an `AchFile` record (specifically the `parsed_data`
        field) must be versioned.
  - [ ] The `paper_trail` gem is recommended for this purpose. It will
        automatically track changes, store previous versions, and record the
        `user_id` of the user who made the change.
- [ ] **UI:** The interface will provide a user-friendly way to edit the ACH
      data, potentially through a structured form or an embedded JSON editor.

### 3.5. ACH File Creation

- [ ] **Functionality:** A step-by-step interface for building a valid ACH file
      from scratch.
- [ ] **Implementation:**
  - [ ] The UI will guide the user through creating a file header, one or more
        batches, and the entries within each batch.
  - [ ] To ensure correctness, the interface will dynamically generate input
        forms based on the record types supported by the `nacha` gem.
  - [ ] It will call `Nacha.ach_record_types` to get the specifications for each
        record type (fields, data types, sizes) and use this information to
        build the forms and apply client-side or server-side validations.

### 3.6. Search

- [ ] **Functionality:** Users can perform detailed searches on the content of their stored ACH files.
- [ ] **Implementation:**
  - [ ] To enable efficient searching within the `parsed_data` JSON column, integration with a search engine like Elasticsearch is recommended.
  - [ ] The `searchkick` gem can be used to integrate Elasticsearch with the `AchFile` model, allowing for complex queries on nested JSON data (e.g., search for a specific `trace_number` or all records with a certain `amount`).

## 4. RESTful API

The API will be versioned (e.g., `/api/v1/`). All responses will be in JSON.

### 4.1. Endpoints

- [ ] **`POST /api/v1/parse/record`**: Parses a single ACH record string.
- [ ] **`POST /api/v1/parse/file`**: Parses a full ACH file.
- [ ] **Output Control:** The desired output format (JSON, HTML, Markdown) can be specified via the `Accept` header.

### 4.2. API Rate Limiting

- [ ] **Functionality:** The API will be rate-limited to prevent abuse.
- [ ] **Implementation:** The `rack-attack` gem should be used.
- [ ] **Response Headers:** The API will return the following headers with every response to inform the client of their current rate limit status:
  - [ ] `X-RateLimit-Limit`: The maximum number of requests allowed in the current window.
  - [ ] `X-RateLimit-Remaining`: The number of requests remaining in the current window.
  - [ ] `X-RateLimit-Reset`: The time (in UTC epoch seconds) when the current window resets.

## 5. Webhooks

### 5.1. Functionality

- [ ] Users can configure webhooks to be notified of events within the application (e.g., `ach_file.parsed`, `ach_file.failed`).
- [ ] A `WebhookEndpoint` model will store the user's endpoint URL and configuration.

### 5.2. Security

Users can choose one of two security mechanisms for their webhook payloads:

1.  **Signed Payloads:**
    - [ ] The user provides a secret token.
    - [ ] The application will generate an HMAC-SHA256 signature of the JSON payload using the secret and include it in the `X-Nacha-Signature-256` request header, allowing the user to verify the payload's integrity.
2.  **Encrypted Payloads:**
    - [ ] The user uploads a public key.
    - [ ] The application will use this key to encrypt the entire JSON payload before sending it, ensuring the data remains confidential in transit.

### 5.3. Implementation

- [ ] A `WebhookDispatchJob` will be enqueued when a trigger event occurs. This job will be responsible for generating the payload, signing or encrypting it, and sending the POST request to the user's configured URL.

## 6. Non-Functional Requirements

- [ ] **Technology Stack:**
  - [ ] **Backend:** Ruby 3.2+, Rails 8.0+
  - [ ] **Database:** PostgreSQL
  - [ ] **Background Jobs:** Solid Queue
  - [ ] **WebSockets:** Action Cable with Solid Cable
  - [ ] **Frontend:** Hotwire (Turbo/Stimulus), Tailwind CSS
  - [ ] **Testing:** RSpec
- [ ] **Security:**
  - [ ] Standard Rails security practices (Strong Parameters, CSRF protection) must be followed.
  - [ ] The `brakeman` gem will be used for static analysis security scanning.
- [ ] **Deployment:** The application will be configured for deployment using Kamal and Docker.
- [ ] **Continuous Integration & Deployment (CI/CD):**
  - [ ] A GitHub Actions workflow will be established in `.github/workflows/ci.yml`.
  - [ ] The workflow will be triggered on every push to the `main` branch and on every pull request targeting `main`.
  - [ ] The CI pipeline will execute the following steps:
    - [ ] **Run RSpec tests:** Ensure all tests pass to prevent regressions.
    - [ ] **Run RuboCop:** Enforce code style and quality standards.
    - [ ] **Run Brakeman:** Scan for potential security vulnerabilities.
  - [ ] A failed step in the pipeline will block the merging of pull requests.
