# Goodnight API

This is the backend API for **Goodnight**, a sleep tracking application. It allows users to track their sleep cycles, follow other users, and view sleep records from the people they follow.

This application is built with Ruby on Rails in API-only mode.

## Table of Contents

* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
  * [Running the Server](#running-the-server)
* [Running Tests](#running-tests)
* [API Endpoints](#api-endpoints)

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* **Ruby**: The version is specified in the `.ruby-version` file.
* **Bundler**: To manage Ruby gems.
* **PostgreSQL**: For the database.

### Installation

1.  **Clone the repository:**

  ```shell
  git clone https://github.com/yosefbennywidyo/goodnight.git
  cd goodnight
  ```

2.  **Install dependencies:**

  ```shell
  bundle install
  ```

3.  **Set up the database:**

  Ensure your PostgreSQL server is running and update `config/database.yml` with your credentials if necessary. Then, run the setup script:

  ```shell
  bin/rails db:setup
  ```

  This will create the database, load the schema, and populate it with seed data.

## Usage

### Running the Server

To start the Rails server, run:

```shell
bin/rails server
```
The API will be available at `http://localhost:3000`.

## Running Tests

The project uses Minitest for testing. To run the entire test suite, execute:

```shell
bin/rails test
```

## API Endpoints

All endpoints are prefixed with `/api/v1`. A `user_id` parameter is required for authentication on most endpoints.

### Users

* `POST /users/:user_id/follow`: Follow another user.
* `DELETE /users/:user_id/unfollow`: Unfollow another user.

### Sleeps

* `GET /sleeps?user_id=<user_id>`: Get all sleep records for the current user, ordered by creation time.
* `POST /sleeps?user_id=<user_id>`: Create a new sleep record (clock-in).
  * **Body**: `{ "sleep": { "clock_in": "YYYY-MM-DDTHH:MM:SSZ" } }`
* `PATCH /sleeps/:id?user_id=<user_id>`: Update a sleep record (clock-out).
  * **Body**: `{ "sleep": { "clock_out": "YYYY-MM-DDTHH:MM:SSZ" } }`

### Friends' Sleeps

* `GET /sleeps/friends_sleeps?user_id=<user_id>`: Get the sleep records of all users followed by the current user from the past week. The records are sorted by sleep duration in descending order.
  * **Query Parameters (optional)**:
    * `start_date` (YYYY-MM-DD)
    * `end_date` (YYYY-MM-DD)
    * `page` (integer)
    * `per_page` (integer)

### Follows

* `POST /follows?user_id=<user_id>`: Follow a user.
  * **Body**: `{ "followed_id": <other_user_id> }`
* `DELETE /follows/:id?user_id=<user_id>`: Unfollow a user (where `:id` is the `followed_id`).
