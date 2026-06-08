# Chill Bites - Flutter F&B Ordering App

Chill Bites is a mobile ordering application for the Food & Beverage industry, built with Flutter and Supabase. The app allows customers to browse food and beverage products, add items to cart, place orders, apply vouchers, review products, manage favorite items, and update their personal profile.

## Overview

Chill Bites focuses on improving the mobile ordering experience with a modern user interface, Light/Dark Mode support, customer ranking based on accumulated points, and personalized theme colors by rank.

The application is suitable for coffee shops, milk tea stores, small restaurants, or F&B businesses that need a basic mobile ordering platform.

## Main Features

* User registration, login, and logout
* Forgot password and password reset via email
* Browse food, beverage, and combo products
* Display product categories with images
* View product details, images, descriptions, prices, and toppings
* Add products to cart
* Select toppings for beverages
* Place orders and save order history
* Update order status
* Automatically update sold quantity when orders are completed
* Apply discount vouchers
* Review purchased products
* Calculate average rating based on real customer reviews
* Save favorite products
* Update user profile and avatar
* Accumulate customer points after each order
* Customer ranking system: Member, Silver, Gold, Diamond
* Change theme color based on customer rank
* Support Light Mode and Dark Mode

## Technologies Used

* Flutter
* Dart
* Supabase Authentication
* Supabase Database
* Supabase Storage
* Riverpod State Management
* Cached Network Image
* Shared Preferences

## Main Database Tables

The application uses Supabase to manage data with the following main tables:

* `customers`: customer information, points, rank, avatar
* `products`: product information
* `categories`: product categories
* `product_images`: product images
* `toppings`: topping list
* `product_toppings`: relationship between products and toppings
* `orders`: order information
* `order_items`: order details
* `reviews`: product reviews
* `vouchers`: discount vouchers

## Main Screens

* Splash Screen
* Onboarding
* Login / Register
* Forgot Password
* Home Page
* Product Detail
* Cart
* Checkout
* Order History
* Review Page
* Profile Page
* Favorites Page
* Settings Page

## Customer Ranking System

Customers earn points after placing orders. Based on the accumulated points, the system automatically assigns a rank.

| Rank    | Points Requirement |              Benefits |
| ------- | -----------------: | --------------------: |
| Member  |            Default |                    0% |
| Silver  |    From 500 points | Configurable benefits |
| Gold    |   From 1000 points | Configurable benefits |
| Diamond |   From 2000 points | Configurable benefits |

Each rank has its own theme color to personalize the user experience.

## Installation and Setup

### 1. Clone the project

```bash
git clone https://github.com/PhiHung112-id/flutter-fnb-ordering-app.git
cd flutter-fnb-ordering-app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

This project uses Supabase for authentication, database, and storage.

Create a local config file:

```text
lib/config/supabase_config.dart
```

### 4. Run the application

```bash
flutter run
```

## Forgot Password Configuration

The application uses Supabase Auth to send password reset emails.

Redirect URL:

```text
io.supabase.chillbites://reset-password
```

This URL must be configured in Supabase:

```text
Authentication → URL Configuration → Redirect URLs
```

The deep link also needs to be added in `AndroidManifest.xml`.

## Project Structure

```text
lib/
├── main.dart
├── models/
├── pages/
├── providers/
├── services/
├── utils/
└── widgets/
```

## Future Development

* Add admin and staff management pages
* Add realtime order notifications
* Integrate online payment
* Improve product search and filtering
* Add AI-based food recommendation based on purchase history
* Add face recognition for customer identification in F&B stores
* Add sales statistics and best-selling product reports

## Author

Developed by Phi Hùng.

## License

This project is developed for learning and graduation project purposes.
