<!-- @format -->

# eCourt Platform for Bhutan's Legal System

The eCourt platform is a Ruby on Rails application designed to digitize and streamline Bhutan's legal system. It provides features such as authentication, notifications, email communication, case registration, case management, role-based access control, digital signatures, report generation, and more. The platform also includes extensive testing using RSpec to ensure reliability and maintainability.

---

## Table of Contents

1. [Features](#features)
2. [Dependencies](#dependencies)
3. [Setup and Installation](#setup-and-installation)
4. [Configuration](#configuration)
5. [Database](#database)
6. [Testing](#testing)
7. [API Documentation](#api-documentation)
8. [Contributing](#contributing)

---

## Features

- **Authentication**: Secure user authentication using Devise and JWT for API-based access.
- **Role-Based Access Control**: Fine-grained access control with roles such as Judge, Clerk, Registrar, Plaintiff, Defendant, Prosecutor, Lawyer, Admin, and User.
- **Case Management**: Comprehensive case registration, assignment, scheduling hearing, managin documents and tracking system with notifications for all participants.
- **Notifications**: Real-time notifications for case updates and user actions, implemented using the `noticed` gem.
- **Email Communication**: Automated email notifications for case updates, reminders, and user actions.
- **Digital Signature**: Integration of digital signature functionality for signing legal documents electronically.
- **Report Generation**: Generate detailed reports (e.g., case summaries, user activity) using background jobs for asynchronous processing.
- **PDF Generation**: Generate court documents and reports in PDF format using WickedPDF.
- **Background Jobs**: Asynchronous task processing using ActiveJob and Sidekiq for tasks like report generation and email delivery.
- **Testing**: Comprehensive test suite using RSpec, FactoryBot, and Shoulda Matchers to ensure code quality and reliability.
- **Swagger API Documentation**: API endpoints are documented using Swagger for easy integration with external systems.
- **Multi-Tenancy**: Court-specific data isolation using the `acts_as_tenant` gem to ensure data security and separation.

---

## Dependencies

The project relies on the following gems and libraries:

- **Authentication**:
  - `devise`
  - `devise-jwt`
- **Authorization**:
  - `pundit`
  - `rolify`
- **Notifications**:
  - `noticed`
- **PDF Generation**:
  - `wicked_pdf`
- **Background Jobs**:
  - `sidekiq`
  - `redis`
- **Testing**:
  - `rspec-rails`
  - `factory_bot_rails`
  - `shoulda-matchers`
  - `faker`
  - `database_cleaner-active_record`
- **API Documentation**:
  - `rswag`
- **Multi-Tenancy**:
  - `acts_as_tenant`
- **Other Utilities**:
  - `jsonapi-serializer`
  - `dotenv-rails`
  - `openssl`
  - `gruff`

For a complete list of dependencies, refer to the [Gemfile](Gemfile).

---

## Setup and Installation

### Prerequisites

- Ruby (version specified in `.ruby-version`)
- Rails (version specified in `Gemfile`)
- PostgreSQL
- Node.js and Yarn
- wkhtmltopdf (for PDF generation)
- Redis (for background jobs)

### Steps

1. Clone the repository:

   ```sh
   git clone git@github.com:ThuktenSingye/edruk-court-backend.git
   cd ecourt-platform

   ```

2. Install dependencies:

- bundle install
- yarn install

3. Set up environment variables:

- Copy .env.example to .env and update the values as needed.

4. Set up the database:

- rails db:create
- rails db:migrate
- rails db:seed

5. Start the server:

- rails server

### Configuration

Devise

- Authentication is handled by Devise with JWT support for API-based authentication.
- Configuration can be found in config/initializers/devise.rb.

Notifications

- Notifications are implemented using the noticed gem.
- Notification-related tables include noticed_events and noticed_notifications.

PDF Generation

- WickedPDF is used for generating court documents.
- Configuration can be found in config/initializers/wicked_pdf.rb.

Background Jobs

- Background jobs are implemented using Solidus Queue a
- Configuration can be found in config/solidus_queue.yml.

### Database

- The application uses PostgreSQL as the database.
- Schema details can be found in db/schema.rb.
- Multi-tenancy is implemented using the acts_as_tenant gem.

### Testing

The project uses RSpec for testing. Key testing tools include:

- FactoryBot: For creating test data.
- Shoulda Matchers: For simplifying model and controller tests.
- Database Cleaner: For ensuring a clean state between tests.

Running Tests
To run the test suite:

- bundle exec rspec

Test configurations can be found in spec/rails_helper.rb and spec/spec_helper.rb.

### API Documentation

API endpoints are documented using Swagger. The Swagger YAML file is located at:

- swagger/v1/swagger.yml
  To view the API documentation, start the server and navigate to /api-docs.

### Contributing

1. For the repository
2. Create a new branch

- git checkout -b feature-name

3. Commit your changes

- git commit -m "Add feature-name"

4. Push to your branch:

- git push origin feature-name

5. Open a pull request
