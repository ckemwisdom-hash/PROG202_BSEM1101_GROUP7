FCC RevTrack – Revenue Collection and Tracking System

Organization: Freetown City Council (FCC), Sierra Leone
Programming Language: Dart
Project Type: Console-Based Application Prototype
Status: Prototype – Stage 1

1. Project Overview

FCC RevTrack is a revenue collection and tracking system designed to improve how Freetown City Council records, monitors, and manages local revenue.

The system addresses challenges associated with manual record-keeping, handwritten receipts, separate spreadsheets, delayed payments, and difficulties tracking outstanding bills.

The prototype demonstrates how a computerized system can register payers, issue bills, record payments, generate numbered receipts, identify overdue bills, and produce revenue reports.

2. Problem Statement

Freetown City Council collects revenue from sources such as market dues, business licenses, and property rates. When records are maintained manually, it can be difficult to determine who has paid, who still owes money, and how much revenue has been collected.

FCC RevTrack proposes a centralized system to improve accuracy, accountability, and efficiency in revenue management.

3. Objectives

The objectives of this project are to:

* Digitize payer, billing, and payment records.
* Improve the accuracy of outstanding balances.
* Reduce payment recording errors.
* Generate numbered payment receipts.
* Identify unpaid and overdue bills.
* Produce revenue collection reports.
* Improve accountability among revenue collectors.

4. Main Features

* User Login: Provides login functionality for managers and revenue collectors.
* Payer Registration: Registers new payers and generates unique payer IDs.
* Payer Search: Searches for payers using their names, phone numbers, or ward numbers.
* Billing Management: Creates bills for market dues, business licenses, and property rates.
* Payment Recording: Records full and partial payments.
* Payment Validation: Rejects zero, negative, and overpayments.
* Receipt Generation: Produces numbered receipts containing payment details.
* Outstanding Bills: Displays unpaid and overdue bills.
* Revenue Reports: Summarizes collections and billed amounts by revenue type.
* Input Validation: Handles invalid entries and prompts users to enter valid information.

5. Technologies Used

* Dart: Programming language used to develop the application.
* Dart SDK: Required to run the program.
* PyCharm: Development environment.
* Git: Version control.
* GitHub: Source code hosting and project documentation.

6. Requirements

Before running the application, ensure that you have:

* Dart SDK installed on your computer.
* A terminal or command prompt.
* A code editor or IDE, such as PyCharm.
* The project’s Dart source file, main.dart.

To verify that Dart is installed, open your terminal and run:

dart --version

7. Installation and Setup

Step 1: Clone the Repository

Replace YOUR-USERNAME with your GitHub username and use your actual repository name.

git clone https://github.com/YOUR-USERNAME/FCC-RevTrack.git

Step 2: Open the Project Folder

cd FCC-RevTrack

Step 3: Run the Application

dart main.dart

The application should start in the terminal and display the FCC RevTrack welcome screen and login menu.

Note: The repository must contain the Dart source file named main.dart for the command above to work.

8. Demo Login Credentials

The prototype includes demonstration accounts.

Role	Username	Password
Manager	admin	admin123
Revenue Collector	officer	officer123

These credentials are for demonstration purposes only. Do not use them as production credentials.

9. How to Use the System

1. Run the application from the terminal.
2. Enter a valid username and password.
3. Select an option from the main menu.
4. View or search for registered payers.
5. View bills and their outstanding balances.
6. Record payments against bills.
7. Generate receipts after confirming payments.
8. View unpaid and overdue bills.
9. Use manager-authorized options to issue bills and view revenue reports.
10. Select the logout option to exit the system.

The program closes after three unsuccessful login attempts.

10. System Design

The prototype uses object-oriented programming and separates responsibilities into several classes and components.

* User and Role: Represent system users and their access roles.
* Payer: Stores payer information.
* Bill: Stores billing information and calculates outstanding balances and payment status.
* Payment: Records payment amounts, receipt numbers, dates, and collectors.
* RevenueSystem: Handles the main business logic, including billing, payments, and reports.
* RevTrackApp: Manages the console menus, input prompts, and displayed output.

The main entities are users, payers, bills, and payments. One payer can have multiple bills, and one bill can have multiple payments.

11. Testing

The report identifies the following test scenarios:

* Logging in with an incorrect password three times.
* Checking access restrictions for revenue collectors.
* Registering and searching for payers.
* Rejecting payments that exceed the outstanding balance.
* Recording full and partial payments.
* Generating receipts and updating payment statuses.
* Displaying unpaid and overdue bills.
* Handling invalid payment amounts.
* Generating revenue reports.

These scenarios are intended to verify that the application’s core business rules work as specified.

12. Limitations

The current prototype has the following limitations:

* Data is stored in memory and is lost when the program closes.
* The interface is console-based rather than graphical.
* Demo payer information and amounts are fictional.
* Passwords are stored in plain text for demonstration purposes.
* A permanent database and production-grade authentication have not yet been implemented.

The prototype is not yet a complete production-ready revenue management system.

13. Future Improvements

Future development will focus on:

* Replacing the console interface with a Flutter application.
* Integrating a Supabase database for persistent storage.
* Implementing secure authentication with Supabase Auth.
* Improving role-based access control.
* Supporting reliable long-term storage of payment records.
* Enhancing reporting and revenue monitoring.
* Preparing the application for Android devices.

14. Project Learning Outcomes

This project demonstrates practical knowledge of:

* Object-oriented programming in Dart.
* Classes, objects, and enumerations.
* Data validation and input handling.
* Collections and computed properties.
* Basic authentication and role-based menus.
* Business logic for billing and payment processing.
* Software requirements analysis and testing.
* Version control and project documentation using Git and GitHub.

15. Author

Project: FCC RevTrack – Revenue Collection and Tracking System
Organization: Freetown City Council, Sierra Leone
Purpose: Software Engineering academic project.

16. License

This project was developed for academic and demonstration purposes. A formal open-source license has not yet been specified.

⸻

FCC RevTrack — Improving Revenue Collection, Accuracy, and Accountability.
