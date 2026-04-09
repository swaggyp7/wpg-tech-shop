# WPG Tech Shop

WPG Tech Shop is a full-stack e-commerce web application built with Ruby on Rails for a consumer electronics and tech retail scenario. It covers the complete shopping flow, including product browsing, user registration and login, cart management, order handling, online payment, and admin-side operations.

This project was designed to demonstrate more than just UI rendering. It simulates a realistic online store with an end-to-end business workflow and highlights my abilities in full-stack web development, domain modeling, payment integration, and admin system implementation.

## Project Overview

- Project type: Full-stack e-commerce web application
- Business scenario: Online storefront for tech products
- Target users: Customers and administrators
- Core value: A complete transaction flow from product discovery to checkout

## Highlights

- End-to-end shopping workflow: product browsing, cart, checkout, and order history
- Admin operations support: products, categories, and orders can be managed through an admin dashboard
- Real payment integration: Stripe Checkout is used for online payment processing
- Business logic closer to real production systems: Canadian province-based tax calculation with tax snapshots stored on orders
- Strong user experience coverage: search, category filtering, price filtering, pagination, discount display, and quantity controls
- Clean engineering structure: Rails MVC architecture with clear separation of concerns and maintainable code organization

## Tech Stack

### Backend

- Ruby 4.0.0
- Ruby on Rails 7.1.3
- Active Record
- Puma

### Frontend

- ERB
- Bootstrap 5
- SCSS
- Hotwire Turbo
- Stimulus
- Importmap

### Data and Storage

- SQLite3
- Active Storage

### Authentication and Admin

- Devise
- ActiveAdmin
- Kaminari

### Payments and Third-Party Services

- Stripe Checkout

### Testing and Developer Tools

- Minitest
- Capybara
- Selenium WebDriver
- Faker
- Docker

## Core Features

### Customer-Facing Features

- Product listing page
- Product detail page
- Product image upload and display
- Product name search
- Category filtering
- Price range filtering
- Product status filtering (on sale, recently updated)
- Pagination
- Discounted price display
- User registration, login, and account profile management
- Add products to cart
- Update cart quantities and remove items
- Automatic subtotal, tax, and total calculation
- Stripe online checkout
- Payment success and cancellation handling
- Order history and order detail viewing

### Admin Features

- Admin authentication
- Product management with image upload
- Category management
- Order tracking and viewing
- Order filtering by status, customer, and date

## Key Business Design

### 1. Complete E-Commerce Flow

Users can browse products, apply filters, add items to the cart, complete payment, and review previous orders. The project models the essential workflow of a real online store.

### 2. Order Snapshot Mechanism

At checkout, product prices, quantities, and tax information are stored directly on the order instead of being recalculated from current product data later. This helps preserve historical accuracy and improves traceability.

### 3. Tax Calculation Logic

The application includes tax rules for Canadian provinces and territories, supporting GST, PST, and HST calculations based on the customer's selected province.

### 4. Reusable Pending Checkout Sessions

When a customer starts checkout, the system creates a pending order based on the current cart and can reuse a still-valid Stripe checkout session for the same cart state, reducing duplicate pending orders.

## Skills Demonstrated in This Project

- Full-stack application development from database design to frontend/backend integration
- Business modeling for products, carts, orders, payments, and tax rules
- Third-party payment integration with Stripe
- Admin dashboard implementation with production-style management workflows
- Maintainable MVC architecture with room for future extension

## Project Structure

```text
app/
  admin/          # ActiveAdmin configuration
  controllers/    # Product, cart, checkout, order, and auth controllers
  models/         # Core business models such as Product, Order, Cart, Customer, Province
  views/          # Storefront pages and Devise views
config/
db/
test/
```

## Run Locally

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Access URLs:

- Storefront: `http://localhost:3000`
- Admin dashboard: `http://localhost:3000/admin`

To enable checkout, configure Stripe test credentials through environment variables or `config/stripe.yml`.

## Keywords for Recruiters

- Full Stack Developer Project
- E-Commerce Web Application
- Ruby on Rails Project
- Stripe Payment Integration
- Admin Dashboard
- Authentication and Order Management

## Summary

This is a business-oriented Rails e-commerce project with a complete transactional flow, not just a static storefront. In addition to customer-facing shopping features, it includes admin management, payment integration, and tax/order snapshot logic, making it a strong project for demonstrating full-stack development and practical system design skills.
