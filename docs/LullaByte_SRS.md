SOFTWARE REQUIREMENTS SPECIFICATION

Document Title: Software Requirements Specification for LullaByte – AI Powered Newborn Care Assistant
Prepared in accordance with: IEEE Std 830-1998 (Recommended Practice for Software Requirements Specifications)
Document Version: 1.1 (Final)
Author: Angel Joseph
Date: 2026-07-20
Status: Final — Submission-Ready

---

## Revision History

| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | 2026-07-19 | Angel Joseph | Initial draft: full specification authored across Sections 1–17, including complete Functional Requirements (Section 10, 21 modules) and Non-Functional, External Interface, Database, Security, Accessibility, Future Scope, and Conclusion sections. |
| 1.1 | 2026-07-20 | Angel Joseph | Documentation review pass: consolidated four duplicate Section 10 headings into a single section, removed internal drafting/construction notes, verified section numbering (1–17, 10.0–10.21) and all internal cross-references for breaks, confirmed no duplicate requirement IDs and no missing Validation Rules/Success Conditions across all 183 functional sub-modules, and added this Table of Contents, Revision History, Document Version, Author, and Date. No requirements were altered, added, or removed. |

---

## Table of Contents

- [1. Introduction](#1-introduction)
  - [1.1 Overview](#11-overview)
  - [1.2 Document Purpose](#12-document-purpose)
  - [1.3 Intended Audience](#13-intended-audience)
  - [1.4 Document Conventions](#14-document-conventions)
  - [1.5 Project Background and Motivation](#15-project-background-and-motivation)
  - [1.6 Project Goals Summary](#16-project-goals-summary)
- [2. Purpose](#2-purpose)
  - [2.1 Purpose of This Document](#21-purpose-of-this-document)
  - [2.2 Purpose of the LullaByte Application](#22-purpose-of-the-lullabyte-application)
  - [2.3 Business and Social Objectives](#23-business-and-social-objectives)
  - [2.4 Success Criteria](#24-success-criteria)
- [3. Scope](#3-scope)
  - [3.1 Product Scope Statement](#31-product-scope-statement)
  - [3.2 In-Scope Capabilities (High-Level)](#32-in-scope-capabilities-high-level)
  - [3.3 Out-of-Scope Items (High-Level)](#33-out-of-scope-items-high-level)
  - [3.4 Deployment Scope](#34-deployment-scope)
  - [3.5 Scope Boundary Note](#35-scope-boundary-note)
- [4. Definitions, Acronyms, and Abbreviations](#4-definitions-acronyms-and-abbreviations)
  - [4.1 Definitions](#41-definitions)
  - [4.2 Acronyms and Abbreviations](#42-acronyms-and-abbreviations)
  - [4.3 Cry Category Reference](#43-cry-category-reference)
- [5. References](#5-references)
  - [5.1 Standards Referenced](#51-standards-referenced)
  - [5.2 Supporting Materials](#52-supporting-materials)
  - [5.3 Related Internal Documents (To Be Produced)](#53-related-internal-documents-to-be-produced)
- [6. Overall Description](#6-overall-description)
  - [6.1 Product Overview](#61-product-overview)
  - [6.2 System Context](#62-system-context)
  - [6.3 Product Positioning](#63-product-positioning)
  - [6.4 Major Product Capability Summary](#64-major-product-capability-summary)
  - [6.5 Operating Environment (Summary)](#65-operating-environment-summary)
  - [6.6 Design and Implementation Constraints (Summary)](#66-design-and-implementation-constraints-summary)
  - [6.7 Assumptions and Dependencies (Summary)](#67-assumptions-and-dependencies-summary)
- [7. Product Perspective](#7-product-perspective)
  - [7.1 System Positioning](#71-system-positioning)
  - [7.2 High-Level System Composition](#72-high-level-system-composition)
  - [7.3 System Interfaces (Conceptual)](#73-system-interfaces-conceptual)
  - [7.4 User Interfaces (Conceptual)](#74-user-interfaces-conceptual)
  - [7.5 Memory, Storage, and Operational Constraints (Conceptual)](#75-memory-storage-and-operational-constraints-conceptual)
  - [7.6 Product Functions Relationship](#76-product-functions-relationship)
- [8. Product Functions](#8-product-functions)
  - [8.1 Purpose of This Section](#81-purpose-of-this-section)
  - [8.2 Summary of Major Product Functions](#82-summary-of-major-product-functions)
  - [8.3 Function Interaction Overview](#83-function-interaction-overview)
  - [8.4 Function Prioritization (MoSCoW Summary)](#84-function-prioritization-moscow-summary)
- [9. User Characteristics](#9-user-characteristics)
  - [9.1 Purpose of This Section](#91-purpose-of-this-section)
  - [9.2 Primary User Personas](#92-primary-user-personas)
    - [9.2.1 Mother](#921-mother)
    - [9.2.2 Father](#922-father)
    - [9.2.3 Caregiver (General, including Deaf Parents)](#923-caregiver-general-including-deaf-parents)
  - [9.3 Secondary User Personas](#93-secondary-user-personas)
    - [9.3.1 Pediatrician](#931-pediatrician)
    - [9.3.2 Grandparents](#932-grandparents)
    - [9.3.3 Babysitter](#933-babysitter)
  - [9.4 Future User Categories](#94-future-user-categories)
  - [9.5 User Characteristics Summary Table](#95-user-characteristics-summary-table)
  - [9.6 Implications for Design](#96-implications-for-design)
- [10. Functional Requirements](#10-functional-requirements)
  - [10.0 Section Conventions](#100-section-conventions)
  - [10.1 Authentication](#101-authentication)
    - [10.1.1 User Registration](#1011-user-registration)
    - [10.1.2 Login](#1012-login)
    - [10.1.3 Google Sign-In](#1013-google-sign-in)
    - [10.1.4 Phone OTP](#1014-phone-otp)
    - [10.1.5 Password Reset](#1015-password-reset)
    - [10.1.6 Session Management](#1016-session-management)
  - [10.2 Parent Registration](#102-parent-registration)
  - [10.3 Baby Registration](#103-baby-registration)
    - [10.3.1 Baby Details](#1031-baby-details)
    - [10.3.2 Birth Information](#1032-birth-information)
    - [10.3.3 Medical Information](#1033-medical-information)
  - [10.4 Twin Baby Registration](#104-twin-baby-registration)
    - [10.4.1 Twin Detection](#1041-twin-detection)
    - [10.4.2 Separate Baby Profiles](#1042-separate-baby-profiles)
    - [10.4.3 Baby Switching](#1043-baby-switching)
    - [10.4.4 Data Separation](#1044-data-separation)
  - [10.5 Dashboard](#105-dashboard)
    - [10.5.1 Dashboard Overview](#1051-dashboard-overview)
    - [10.5.2 Daily Summary](#1052-daily-summary)
    - [10.5.3 Quick Actions](#1053-quick-actions)
    - [10.5.4 Recent Activities](#1054-recent-activities)
    - [10.5.5 Statistics](#1055-statistics)
    - [10.5.6 Navigation](#1056-navigation)
  - [10.6 AI Cry Analyzer](#106-ai-cry-analyzer)
    - [10.6.1 Live Recording](#1061-live-recording)
    - [10.6.2 Upload Audio](#1062-upload-audio)
    - [10.6.3 Audio Validation](#1063-audio-validation)
    - [10.6.4 Baby Cry Detection](#1064-baby-cry-detection)
    - [10.6.5 Non-Baby Sound Detection](#1065-non-baby-sound-detection)
    - [10.6.6 Noise Reduction](#1066-noise-reduction)
    - [10.6.7 Feature Extraction](#1067-feature-extraction)
    - [10.6.8 AI Prediction](#1068-ai-prediction)
    - [10.6.9 Confidence Score](#1069-confidence-score)
    - [10.6.10 Probability Distribution](#10610-probability-distribution)
    - [10.6.11 Recommendations](#10611-recommendations)
    - [10.6.12 Prediction History](#10612-prediction-history)
    - [10.6.13 Audio Playback](#10613-audio-playback)
    - [10.6.14 Delete History](#10614-delete-history)
  - [10.7 Feeding Tracker](#107-feeding-tracker)
    - [10.7.1 Breastfeeding](#1071-breastfeeding)
    - [10.7.2 Bottle Feeding](#1072-bottle-feeding)
    - [10.7.3 Formula Feeding](#1073-formula-feeding)
    - [10.7.4 Solid Feeding](#1074-solid-feeding)
    - [10.7.5 Feeding Timer](#1075-feeding-timer)
    - [10.7.6 Left Breast](#1076-left-breast)
    - [10.7.7 Right Breast](#1077-right-breast)
    - [10.7.8 Both Breasts](#1078-both-breasts)
    - [10.7.9 Feeding History](#1079-feeding-history)
    - [10.7.10 Daily Statistics](#10710-daily-statistics)
    - [10.7.11 Weekly Statistics](#10711-weekly-statistics)
    - [10.7.12 Monthly Statistics](#10712-monthly-statistics)
  - [10.8 Sleep Tracker](#108-sleep-tracker)
    - [10.8.1 Sleep Start](#1081-sleep-start)
    - [10.8.2 Sleep End](#1082-sleep-end)
    - [10.8.3 Duration](#1083-duration)
    - [10.8.4 Day Sleep](#1084-day-sleep)
    - [10.8.5 Night Sleep](#1085-night-sleep)
    - [10.8.6 Sleep History](#1086-sleep-history)
    - [10.8.7 Daily Sleep Statistics](#1087-daily-sleep-statistics)
    - [10.8.8 Weekly Sleep Statistics](#1088-weekly-sleep-statistics)
    - [10.8.9 Monthly Sleep Statistics](#1089-monthly-sleep-statistics)
  - [10.9 Diaper Tracker](#109-diaper-tracker)
    - [10.9.1 Pee](#1091-pee)
    - [10.9.2 Poop](#1092-poop)
    - [10.9.3 Mixed](#1093-mixed)
    - [10.9.4 Dry](#1094-dry)
    - [10.9.5 Size](#1095-size)
    - [10.9.6 Color](#1096-color)
    - [10.9.7 Notes](#1097-notes)
    - [10.9.8 History (Timeline)](#1098-history-timeline)
    - [10.9.9 Daily Statistics](#1099-daily-statistics)
    - [10.9.10 Weekly Statistics](#10910-weekly-statistics)
  - [10.10 Vaccination Management](#1010-vaccination-management)
    - [10.10.1 Vaccination Schedule](#10101-vaccination-schedule)
    - [10.10.2 Upcoming Vaccinations](#10102-upcoming-vaccinations)
    - [10.10.3 Completed Vaccinations](#10103-completed-vaccinations)
    - [10.10.4 Pending Vaccinations](#10104-pending-vaccinations)
    - [10.10.5 Missed Vaccinations](#10105-missed-vaccinations)
    - [10.10.6 Doctor Information](#10106-doctor-information)
    - [10.10.7 Hospital Information](#10107-hospital-information)
    - [10.10.8 Appointment Scheduling](#10108-appointment-scheduling)
    - [10.10.9 Reminder Notifications](#10109-reminder-notifications)
    - [10.10.10 Vaccination History](#101010-vaccination-history)
    - [10.10.11 Progress Tracking](#101011-progress-tracking)
  - [10.11 Milestone Tracking](#1011-milestone-tracking)
    - [10.11.1 Development Timeline](#10111-development-timeline)
    - [10.11.2 Expected Age](#10112-expected-age)
    - [10.11.3 Achievement Date](#10113-achievement-date)
    - [10.11.4 Photos](#10114-photos)
    - [10.11.5 Videos](#10115-videos)
    - [10.11.6 Notes](#10116-notes)
    - [10.11.7 Progress Percentage](#10117-progress-percentage)
    - [10.11.8 Milestone History](#10118-milestone-history)
  - [10.12 Gallery](#1012-gallery)
    - [10.12.1 Photo Upload](#10121-photo-upload)
    - [10.12.2 Video Upload](#10122-video-upload)
    - [10.12.3 Timeline View](#10123-timeline-view)
    - [10.12.4 Grid View](#10124-grid-view)
    - [10.12.5 Search](#10125-search)
    - [10.12.6 Filter](#10126-filter)
    - [10.12.7 Cloud Backup](#10127-cloud-backup)
    - [10.12.8 Offline Storage](#10128-offline-storage)
    - [10.12.9 Delete](#10129-delete)
    - [10.12.10 Restore](#101210-restore)
  - [10.13 Baby Profile](#1013-baby-profile)
    - [10.13.1 Baby Details](#10131-baby-details)
    - [10.13.2 Parent Details](#10132-parent-details)
    - [10.13.3 Medical Information](#10133-medical-information)
    - [10.13.4 Growth Information](#10134-growth-information)
    - [10.13.5 Hospital Information](#10135-hospital-information)
    - [10.13.6 Doctor Information](#10136-doctor-information)
    - [10.13.7 Allergies](#10137-allergies)
    - [10.13.8 Emergency Contacts](#10138-emergency-contacts)
    - [10.13.9 Edit Profile](#10139-edit-profile)
  - [10.14 Growth Records](#1014-growth-records)
    - [10.14.1 Weight Tracking](#10141-weight-tracking)
    - [10.14.2 Height Tracking](#10142-height-tracking)
    - [10.14.3 Head Circumference](#10143-head-circumference)
    - [10.14.4 BMI (Future Support)](#10144-bmi-future-support)
    - [10.14.5 Growth Charts](#10145-growth-charts)
    - [10.14.6 Growth History](#10146-growth-history)
    - [10.14.7 Export Growth Report](#10147-export-growth-report)
  - [10.15 AI Parenting Assistant](#1015-ai-parenting-assistant)
    - [10.15.1 AI Chat](#10151-ai-chat)
    - [10.15.2 Parenting Guidance](#10152-parenting-guidance)
    - [10.15.3 Feeding Advice](#10153-feeding-advice)
    - [10.15.4 Sleeping Advice](#10154-sleeping-advice)
    - [10.15.5 Vaccination Guidance](#10155-vaccination-guidance)
    - [10.15.6 Growth Guidance](#10156-growth-guidance)
    - [10.15.7 Health Education](#10157-health-education)
    - [10.15.8 Conversation History](#10158-conversation-history)
    - [10.15.9 AI Safety Disclaimer](#10159-ai-safety-disclaimer)
  - [10.16 Reports and Analytics](#1016-reports-and-analytics)
    - [10.16.1 Daily Reports](#10161-daily-reports)
    - [10.16.2 Weekly Reports](#10162-weekly-reports)
    - [10.16.3 Monthly Reports](#10163-monthly-reports)
    - [10.16.4 Feeding Analytics](#10164-feeding-analytics)
    - [10.16.5 Sleep Analytics](#10165-sleep-analytics)
    - [10.16.6 Cry Analytics](#10166-cry-analytics)
    - [10.16.7 Growth Analytics](#10167-growth-analytics)
    - [10.16.8 Vaccination Analytics](#10168-vaccination-analytics)
    - [10.16.9 Diaper Analytics](#10169-diaper-analytics)
    - [10.16.10 Export PDF](#101610-export-pdf)
    - [10.16.11 Export CSV](#101611-export-csv)
    - [10.16.12 Data Visualization](#101612-data-visualization)
    - [10.16.13 Charts and Graphs](#101613-charts-and-graphs)
  - [10.17 Notification System](#1017-notification-system)
    - [10.17.1 Feeding Reminder](#10171-feeding-reminder)
    - [10.17.2 Sleeping Reminder](#10172-sleeping-reminder)
    - [10.17.3 Vaccination Reminder](#10173-vaccination-reminder)
    - [10.17.4 Medication Reminder](#10174-medication-reminder)
    - [10.17.5 Milestone Reminder](#10175-milestone-reminder)
    - [10.17.6 Daily Encouragement](#10176-daily-encouragement)
    - [10.17.7 Push Notifications](#10177-push-notifications)
    - [10.17.8 Local Notifications](#10178-local-notifications)
    - [10.17.9 Notification History](#10179-notification-history)
    - [10.17.10 Notification Preferences](#101710-notification-preferences)
  - [10.18 Offline Synchronization](#1018-offline-synchronization)
    - [10.18.1 Offline Data Storage](#10181-offline-data-storage)
    - [10.18.2 SQLite Local Database](#10182-sqlite-local-database)
    - [10.18.3 Synchronization Queue](#10183-synchronization-queue)
    - [10.18.4 Automatic Synchronization](#10184-automatic-synchronization)
    - [10.18.5 Manual Synchronization](#10185-manual-synchronization)
    - [10.18.6 Conflict Detection](#10186-conflict-detection)
    - [10.18.7 Conflict Resolution](#10187-conflict-resolution)
    - [10.18.8 Retry Mechanism](#10188-retry-mechanism)
    - [10.18.9 Sync Status](#10189-sync-status)
    - [10.18.10 Error Recovery](#101810-error-recovery)
    - [10.18.11 Background Synchronization](#101811-background-synchronization)
  - [10.19 Search](#1019-search)
    - [10.19.1 Global Search](#10191-global-search)
    - [10.19.2 Search by Baby](#10192-search-by-baby)
    - [10.19.3 Search by Date](#10193-search-by-date)
    - [10.19.4 Search by Category](#10194-search-by-category)
    - [10.19.5 Filters](#10195-filters)
    - [10.19.6 Sorting](#10196-sorting)
    - [10.19.7 Search History](#10197-search-history)
    - [10.19.8 Quick Search](#10198-quick-search)
    - [10.19.9 Advanced Search](#10199-advanced-search)
  - [10.20 Family Sharing](#1020-family-sharing)
    - [10.20.1 Invite Family Members](#10201-invite-family-members)
    - [10.20.2 Invite Caregivers](#10202-invite-caregivers)
    - [10.20.3 Invite Doctors](#10203-invite-doctors)
    - [10.20.4 Role-Based Permissions](#10204-role-based-permissions)
    - [10.20.5 View Only Access](#10205-view-only-access)
    - [10.20.6 Edit Access](#10206-edit-access)
    - [10.20.7 Full Access](#10207-full-access)
    - [10.20.8 Remove Member](#10208-remove-member)
    - [10.20.9 Shared Notifications](#10209-shared-notifications)
    - [10.20.10 Shared Baby Records](#102010-shared-baby-records)
  - [10.21 Settings](#1021-settings)
    - [10.21.1 Profile Settings](#10211-profile-settings)
    - [10.21.2 Theme Settings](#10212-theme-settings)
    - [10.21.3 Language Settings](#10213-language-settings)
    - [10.21.4 Notification Preferences](#10214-notification-preferences)
    - [10.21.5 Privacy Settings](#10215-privacy-settings)
    - [10.21.6 Security Settings](#10216-security-settings)
    - [10.21.7 Accessibility Settings](#10217-accessibility-settings)
    - [10.21.8 Backup & Restore](#10218-backup-restore)
    - [10.21.9 Data Export](#10219-data-export)
    - [10.21.10 Account Management](#102110-account-management)
    - [10.21.11 Logout](#102111-logout)
- [11. Non-Functional Requirements](#11-non-functional-requirements)
  - [11.0 Section Conventions](#110-section-conventions)
  - [11.1 Performance](#111-performance)
    - [11.1.1 Response Time](#1111-response-time)
    - [11.1.2 Startup Time](#1112-startup-time)
    - [11.1.3 AI Prediction Time](#1113-ai-prediction-time)
    - [11.1.4 Database Performance](#1114-database-performance)
    - [11.1.5 Synchronization Performance](#1115-synchronization-performance)
    - [11.1.6 Scalability (Performance Dimension)](#1116-scalability-performance-dimension)
  - [11.2 Reliability](#112-reliability)
    - [11.2.1 Fault Tolerance](#1121-fault-tolerance)
    - [11.2.2 Error Recovery](#1122-error-recovery)
    - [11.2.3 Data Integrity](#1123-data-integrity)
    - [11.2.4 Backup](#1124-backup)
    - [11.2.5 Availability](#1125-availability)
  - [11.3 Usability](#113-usability)
    - [11.3.1 Easy Navigation](#1131-easy-navigation)
    - [11.3.2 User-Friendly Design](#1132-user-friendly-design)
    - [11.3.3 Minimal Learning Curve](#1133-minimal-learning-curve)
    - [11.3.4 Consistent UI](#1134-consistent-ui)
    - [11.3.5 Responsive Design](#1135-responsive-design)
  - [11.4 Maintainability](#114-maintainability)
    - [11.4.1 Modular Architecture](#1141-modular-architecture)
    - [11.4.2 Clean Code](#1142-clean-code)
    - [11.4.3 Documentation](#1143-documentation)
    - [11.4.4 Logging](#1144-logging)
    - [11.4.5 Monitoring](#1145-monitoring)
  - [11.5 Scalability](#115-scalability)
    - [11.5.1 Multiple Babies](#1151-multiple-babies)
    - [11.5.2 Twin Support](#1152-twin-support)
    - [11.5.3 Large User Base](#1153-large-user-base)
    - [11.5.4 Future Features](#1154-future-features)
  - [11.6 Portability](#116-portability)
    - [11.6.1 Android](#1161-android)
    - [11.6.2 iOS](#1162-ios)
    - [11.6.3 Tablet](#1163-tablet)
    - [11.6.4 Web](#1164-web)
- [12. External Interface Requirements](#12-external-interface-requirements)
  - [12.1 User Interface](#121-user-interface)
  - [12.2 Hardware Interface](#122-hardware-interface)
  - [12.3 Software Interface](#123-software-interface)
  - [12.4 Communication Interface](#124-communication-interface)
  - [12.5 API Interface](#125-api-interface)
  - [12.6 Firebase Integration](#126-firebase-integration)
  - [12.7 Cloudinary Integration](#127-cloudinary-integration)
  - [12.8 Microphone](#128-microphone)
  - [12.9 Camera](#129-camera)
  - [12.10 Gallery (Device Media Library)](#1210-gallery-device-media-library)
  - [12.11 Notification Services](#1211-notification-services)
- [13. Database Requirements](#13-database-requirements)
  - [13.1 PostgreSQL (Cloud Structured Data Store)](#131-postgresql-cloud-structured-data-store)
  - [13.2 SQLite (Local Structured Data Store)](#132-sqlite-local-structured-data-store)
  - [13.3 Offline Database (Behavioral Requirements)](#133-offline-database-behavioral-requirements)
  - [13.4 Synchronization Strategy](#134-synchronization-strategy)
  - [13.5 Entity Relationships (High-Level)](#135-entity-relationships-high-level)
  - [13.6 Data Retention](#136-data-retention)
  - [13.7 Backup Strategy](#137-backup-strategy)
  - [13.8 Indexes](#138-indexes)
  - [13.9 Transactions](#139-transactions)
  - [13.10 Audit Logs](#1310-audit-logs)
- [14. Security Requirements](#14-security-requirements)
  - [14.1 JWT Authentication](#141-jwt-authentication)
  - [14.2 Password Hashing](#142-password-hashing)
  - [14.3 Role-Based Access Control](#143-role-based-access-control)
  - [14.4 HTTPS](#144-https)
  - [14.5 Encrypted SQLite](#145-encrypted-sqlite)
  - [14.6 Encrypted API Communication](#146-encrypted-api-communication)
  - [14.7 Data Privacy](#147-data-privacy)
  - [14.8 User Consent](#148-user-consent)
  - [14.9 GDPR Readiness](#149-gdpr-readiness)
  - [14.10 Input Validation](#1410-input-validation)
  - [14.11 SQL Injection Prevention](#1411-sql-injection-prevention)
  - [14.12 Cross-Site Scripting Prevention](#1412-cross-site-scripting-prevention)
  - [14.13 Secure File Upload](#1413-secure-file-upload)
  - [14.14 Session Management (Security Dimension)](#1414-session-management-security-dimension)
  - [14.15 API Security](#1415-api-security)
- [15. Accessibility Requirements](#15-accessibility-requirements)
  - [15.1 Purpose and Guiding Principle](#151-purpose-and-guiding-principle)
  - [15.2 Visual Notifications](#152-visual-notifications)
  - [15.3 Vibration Alerts](#153-vibration-alerts)
  - [15.4 Large Buttons](#154-large-buttons)
  - [15.5 Large Fonts](#155-large-fonts)
  - [15.6 Color Indicators](#156-color-indicators)
  - [15.7 Simple Navigation](#157-simple-navigation)
  - [15.8 Readable Icons](#158-readable-icons)
  - [15.9 Screen Reader Compatibility](#159-screen-reader-compatibility)
  - [15.10 High Contrast Mode](#1510-high-contrast-mode)
  - [15.11 Accessibility Settings](#1511-accessibility-settings)
- [16. Future Scope](#16-future-scope)
  - [16.1 Purpose](#161-purpose)
  - [16.2 Hardware and IoT Integration](#162-hardware-and-iot-integration)
  - [16.3 Healthcare System Integration](#163-healthcare-system-integration)
  - [16.4 AI and Machine Learning Improvements](#164-ai-and-machine-learning-improvements)
  - [16.5 Platform and Reach Expansion](#165-platform-and-reach-expansion)
- [17. Conclusion](#17-conclusion)
  - [17.1 Project Vision](#171-project-vision)
  - [17.2 Objectives Realized Through This Specification](#172-objectives-realized-through-this-specification)
  - [17.3 Expected Benefits](#173-expected-benefits)
  - [17.4 Future Expansion](#174-future-expansion)
  - [17.5 Impact on Parents](#175-impact-on-parents)
  - [17.6 Impact on Healthcare](#176-impact-on-healthcare)
  - [17.7 Closing Statement](#177-closing-statement)

---

# 1. Introduction

## 1.1 Overview

LullaByte is an AI-powered newborn care assistant application designed to support parents and caregivers — with a specific emphasis on deaf parents and first-time parents — in understanding and managing the day-to-day needs of a newborn child. The application combines an artificial intelligence-based infant cry analysis engine with a comprehensive newborn care management platform, encompassing feeding, sleep, diaper, vaccination, milestone, growth, and health record tracking.

LullaByte is not limited to cry classification. It is conceived as a complete newborn management ecosystem that operates both online and offline, synchronizes data across devices and family members, and provides actionable, AI-assisted guidance to reduce parental stress and improve infant care outcomes.

## 1.2 Document Purpose

This Software Requirements Specification (SRS) document describes, in detail, the functional and non-functional requirements of the LullaByte application. It is intended to serve as the single authoritative source of truth for all stakeholders involved in the design, development, testing, deployment, and future enhancement of the system.

This document is written in accordance with the IEEE Std 830-1998 recommended practice for software requirements specifications, and is structured to be suitable both as an academic final-year engineering project deliverable and as a foundation for production-grade product development.

## 1.3 Intended Audience

This document is intended for the following audiences:

| Audience | Purpose of Use |
|---|---|
| Software Architects | To design system architecture aligned with documented requirements |
| Backend and Mobile Developers | To implement functional modules as specified |
| AI/ML Engineers | To understand data, model, and inference requirements for the Cry Analyzer and AI Assistant |
| QA and Test Engineers | To derive test cases and acceptance criteria |
| UI/UX Designers | To design interfaces consistent with accessibility and usability requirements |
| Database Architects | To design schemas satisfying data requirements |
| Project Evaluators / Academic Reviewers | To assess completeness and technical soundness of the project |
| Product Owners / Stakeholders | To validate that business objectives are captured correctly |
| Future Maintainers | To understand system scope and rationale for future enhancement |

## 1.4 Document Conventions

- Requirements are uniquely identified using the format **[Module-Prefix]-[Number]** (e.g., FR-CRY-01, NFR-SEC-03).
- The keywords **MUST**, **SHALL**, **SHOULD**, and **MAY** are used to indicate requirement priority, consistent with standard requirements engineering practice:
  - **MUST / SHALL** — mandatory requirement.
  - **SHOULD** — recommended, high-priority requirement.
  - **MAY** — optional or future-scope requirement.
- Tables are used extensively to present structured requirement data (inputs, outputs, validation rules).
- Section 10 (Functional Requirements) applies the eleven-part module template (Purpose, Description, Inputs, Outputs, Preconditions, Postconditions, User Actions, System Behaviour, Validation Rules, Error Handling, Success Conditions) uniformly across all 183 functional sub-modules. Sections 11–17 present requirements as identifier-tagged tables, consistent with the conventions restated in Sections 10.0 and 11.0.

## 1.5 Project Background and Motivation

Newborn care is a period of significant physical and emotional stress for parents, particularly first-time parents who lack prior experience interpreting infant needs. Among the earliest and most persistent challenges is interpreting an infant's cry — a primary communication mechanism for babies who cannot yet express needs verbally.

This challenge is substantially amplified for **deaf parents**, who cannot audibly perceive their baby's cries at all, creating a critical accessibility gap in existing newborn care solutions. Existing baby monitoring products in the market largely assume a hearing caregiver and provide, at most, generic audio alerts without interpretation, analysis, or accessible non-auditory feedback mechanisms.

LullaByte is motivated by the need to close this gap by combining:

1. An AI-based cry classification engine capable of distinguishing cry categories (e.g., hungry, tired, discomfort, belly pain) and non-cry sounds.
2. Strong visual, haptic, and accessibility-first design suited to deaf and hard-of-hearing users.
3. A unified newborn care record-keeping system that reduces the cognitive burden on parents by consolidating feeding, sleep, diaper, health, vaccination, and milestone data in a single, offline-capable, cloud-synchronized platform.

## 1.6 Project Goals Summary

LullaByte aims to deliver a production-ready, scalable mobile-first application (with future Play Store and App Store deployment) that:

- Assists parents in interpreting newborn cries using AI.
- Provides accessible, deaf-friendly interaction patterns throughout the application.
- Consolidates comprehensive newborn care tracking into a single platform.
- Functions reliably in low-connectivity or offline conditions.
- Synchronizes data securely across devices and family members.
- Supports long-term retention of growth and health records for future reference (e.g., pediatric visits).

---

# 2. Purpose

## 2.1 Purpose of This Document

The purpose of this SRS document is to comprehensively define the functional and non-functional requirements of the LullaByte application such that:

- Development teams can design and implement the system without requiring clarification on core scope or behavior.
- Testing teams can derive verifiable acceptance criteria for every module.
- Stakeholders have a single point of reference for what the system will and will not do at each stage of delivery.
- The document can act as a durable technical and academic artifact, suitable for evaluation, extension, and future product development.

This document defines **what** the system shall do, not **how** it shall be implemented in code. Implementation-level source code is explicitly outside the scope of this document.

## 2.2 Purpose of the LullaByte Application

The LullaByte application itself (as distinct from this document) is designed to:

1. **Interpret infant cries using artificial intelligence**, providing probability-based predictions across defined cry categories (e.g., hungry, tired, discomfort, belly pain, gas) as well as detection of non-cry audio (e.g., speech, music, ambient noise).
2. **Enable deaf parents** to receive visual and haptic interpretations of their baby's cries and needs, removing reliance on auditory perception.
3. **Support first-time parents and caregivers** with structured guidance, reminders, and an AI parenting assistant for common newborn care questions.
4. **Maintain a complete digital record of newborn care activities**, including feeding, sleeping, diaper changes, vaccinations, growth milestones, and media (photos/videos), replacing fragmented paper logs, spreadsheets, or memory-based tracking.
5. **Operate reliably without continuous internet connectivity**, with automatic synchronization to the cloud once connectivity is restored.
6. **Support multiple caregivers and family members** through role-based, shared access to a baby's profile and records.
7. **Support multiple babies per family**, including simultaneous tracking for twins or multiple children.
8. **Provide long-term analytics and reports** derived from logged data, useful for both parental insight and pediatric consultations.

## 2.3 Business and Social Objectives

| Objective | Description |
|---|---|
| Accessibility for deaf parents | Provide a primary, non-auditory channel for understanding infant cries and needs |
| Parental stress reduction | Consolidate newborn care activities and provide AI-assisted guidance to reduce uncertainty and cognitive load |
| Improved newborn care quality | Use data-driven tracking and AI recommendations to support more consistent, informed caregiving |
| Data continuity and portability | Maintain long-term, exportable growth and health records usable across pediatric visits and caregivers |
| Offline-first accessibility | Ensure usability in homes or regions with unreliable internet connectivity |
| Multi-caregiver collaboration | Enable synchronized, shared caregiving across parents, family members, and babysitters |
| Scalability for future markets | Architect the system to scale toward commercial deployment on Play Store and App Store, and toward future institutional use (hospitals, clinics, childcare centers) |

## 2.4 Success Criteria

The LullaByte application shall be considered successful in fulfilling its purpose if it:

- Provides cry analysis predictions with clearly communicated confidence levels and recommendations.
- Correctly distinguishes non-cry audio from baby cry audio and avoids false cry classification.
- Allows complete, uninterrupted use of core tracking features (feeding, sleep, diaper) without an internet connection.
- Synchronizes offline-recorded data to the cloud without data loss upon reconnection.
- Presents critical alerts and information through visual and haptic channels, not exclusively audio.
- Supports secure, role-based multi-user access to a shared baby profile.
- Maintains data integrity and security in accordance with the security requirements defined in this document.

---

# 3. Scope

## 3.1 Product Scope Statement

LullaByte is a cross-platform mobile application (with a supporting backend service and cloud infrastructure) that functions as a comprehensive newborn care management platform augmented by artificial intelligence. The product scope spans two tightly integrated pillars:

1. **AI-Assisted Interpretation** — cry analysis and an AI parenting assistant.
2. **Newborn Care Management** — structured tracking of feeding, sleep, diapers, vaccinations, milestones, growth, and media, supported by offline capability, cloud synchronization, multi-baby and multi-user support, notifications, reports, and analytics.

The detailed functional scope, module-by-module functional requirements, non-functional requirements, and interface/database/security specifications are addressed in subsequent parts of this document. Section 3.2 below defines the boundary of what is included and excluded from the product scope at a high level; a complete modular breakdown (System Scope) is provided in a later part of this document as previously outlined.

## 3.2 In-Scope Capabilities (High-Level)

The following capabilities are within the scope of the LullaByte product:

- AI-powered cry recording, upload, and classification with historical prediction storage.
- Detection and rejection of non-cry audio inputs (e.g., speech, music, ambient noise, animal sounds).
- Baby profile management, including support for single, multiple, and twin babies.
- Feeding tracking (breastfeeding, bottle feeding, formula feeding, solid feeding).
- Sleep tracking with day/night classification and quality indicators.
- Diaper tracking with type, size, color, and notes.
- Vaccination scheduling, reminders, and status tracking.
- Milestone tracking with expected-age guidance and media attachment.
- Growth record tracking (weight, height, and related metrics over time).
- Media gallery with automatic categorization and cloud backup.
- AI parenting assistant for informational (non-diagnostic) guidance.
- Notification system covering reminders, alerts, and sync status.
- Offline-first local data storage with automatic cloud synchronization.
- Role-based multi-user family sharing of baby profiles and records.
- Reports and analytics derived from logged data.
- Application-wide search across records and media.
- Accessibility-first design, with specific accommodations for deaf users.
- Security controls including authentication, encryption, and role-based access control.

## 3.3 Out-of-Scope Items (High-Level)

The following are explicitly out of scope for the LullaByte application as defined in this document:

- Medical diagnosis of any kind. The AI Cry Analyzer and AI Assistant provide informational guidance only and do not replace professional pediatric medical evaluation.
- Direct integration with hospital Electronic Health Record (EHR) systems in the initial release (identified as a **Future Enhancement**, addressed later in this document).
- Direct integration with third-party wearable devices or smart hardware (baby monitors, smart cradles, temperature sensors) in the initial release (identified as a **Future Enhancement**).
- Telemedicine or direct communication channels with licensed medical professionals within the application.
- Payment processing or e-commerce functionality.
- Source code, implementation architecture diagrams, or algorithmic implementation details — this document specifies requirements only, not design or code.

## 3.4 Deployment Scope

LullaByte is intended for deployment as a mobile-first cross-platform application with a supporting backend and cloud infrastructure, architected to scale toward public release on the Google Play Store and Apple App Store. The system constraints and target technology stack are addressed in a later part of this document.

## 3.5 Scope Boundary Note

This Part 1 document establishes the introductory and referential foundation of the SRS. Detailed system scope (module-by-module), functional requirements, non-functional requirements, external interface requirements, database requirements, security requirements, accessibility requirements, and future scope are addressed in subsequent parts of this document, to be generated upon confirmation, consistent with the multi-part delivery structure requested for this specification.

---

# 4. Definitions, Acronyms, and Abbreviations

## 4.1 Definitions

| Term | Definition |
|---|---|
| **Cry Analyzer** | The AI subsystem responsible for classifying recorded or uploaded infant audio into predefined cry categories or non-cry categories. |
| **Cry Category** | A classification label representing a probable cause of an infant's cry (e.g., Hungry, Sleepy, Discomfort, Gas, Belly Pain). |
| **Confidence Score** | A numerical probability value, expressed as a percentage, indicating the AI model's confidence in a given prediction. |
| **Prediction History** | A persisted, chronological record of past cry analysis results associated with a baby profile. |
| **Baby Profile** | A structured data record representing an individual infant, including identity, birth, and medical information. |
| **Twin Baby Support** | Functionality allowing simultaneous creation and management of two or more linked baby profiles sharing the same caregiving household. |
| **Caregiver** | Any individual (parent, family member, babysitter, or professional) granted access to manage or view a baby's profile and records. |
| **Role-Based Access** | An access control model in which system permissions are determined by the role assigned to a user (e.g., Parent, Caregiver, Viewer). |
| **Offline Mode** | Application operation without an active internet connection, relying on local data storage. |
| **Cloud Synchronization (Sync)** | The process of reconciling locally stored data with a remote cloud data store once connectivity is available. |
| **Family Sharing** | Functionality enabling multiple user accounts to access and collaboratively manage the same baby profile(s). |
| **Milestone** | A recognized developmental achievement (e.g., First Smile, Rolling Over, First Word) tracked against expected age ranges. |
| **AI Parenting Assistant** | A conversational AI feature providing informational responses to parenting-related queries, explicitly excluding medical diagnosis. |
| **Deaf-Accessible Design** | Interface and notification design patterns that convey information through visual and haptic means rather than relying on audio alone. |
| **Growth Record** | A timestamped entry capturing a baby's physical growth metrics (e.g., weight, height, head circumference). |
| **Vaccination Schedule** | A structured list of required or recommended immunizations, along with their due dates and completion status. |

## 4.2 Acronyms and Abbreviations

| Acronym | Expansion |
|---|---|
| **SRS** | Software Requirements Specification |
| **AI** | Artificial Intelligence |
| **ML** | Machine Learning |
| **UI** | User Interface |
| **UX** | User Experience |
| **API** | Application Programming Interface |
| **JWT** | JSON Web Token |
| **HTTPS** | Hypertext Transfer Protocol Secure |
| **CRUD** | Create, Read, Update, Delete |
| **FR** | Functional Requirement |
| **NFR** | Non-Functional Requirement |
| **DB** | Database |
| **UUID** | Universally Unique Identifier |
| **RBAC** | Role-Based Access Control |
| **IEEE** | Institute of Electrical and Electronics Engineers |
| **iOS** | Apple's Mobile Operating System |
| **ml (unit)** | Millilitre (used for feeding volume) |
| **EHR** | Electronic Health Record |
| **CDN** | Content Delivery Network |
| **QA** | Quality Assurance |
| **MVP** | Minimum Viable Product |

## 4.3 Cry Category Reference

The following cry categories are used consistently throughout this document and the LullaByte system, aligned with the underlying training dataset structure:

| Category | Description |
|---|---|
| Hungry | Cry pattern associated with feeding need |
| Tired / Sleepy | Cry pattern associated with the need for sleep or rest |
| Discomfort | Cry pattern associated with general physical discomfort (e.g., wet diaper, temperature) |
| Belly Pain | Cry pattern associated with abdominal discomfort |
| Gas | Cry pattern associated with gas-related discomfort |
| Noise / Non-Cry | Audio input identified as not being an infant cry (e.g., speech, music, ambient noise, animal sounds, television) |

---

# 5. References

## 5.1 Standards Referenced

| Reference | Description |
|---|---|
| IEEE Std 830-1998 | IEEE Recommended Practice for Software Requirements Specifications — structural and content basis for this document |
| ISO/IEC/IEEE 29148:2018 | Systems and software engineering — Life cycle processes — Requirements engineering (supplementary reference for requirements quality attributes) |
| WCAG 2.1 (Web Content Accessibility Guidelines) | Referenced for accessibility design principles applicable to deaf and hard-of-hearing users |
| OWASP Top 10 | Referenced for baseline security requirement considerations |

## 5.2 Supporting Materials

| Reference | Description |
|---|---|
| Infant Cry Classification Dataset | Locally referenced dataset organized into categories: `belly_pain`, `discomfort`, `hungry`, `noise`, `tired`, used as the basis for AI Cry Analyzer category definitions |
| Standard Pediatric Vaccination Schedules | General reference for structuring the vaccination scheduling module (region-specific schedules to be configurable) |
| Standard Infant Developmental Milestone Charts | General reference for structuring expected-age milestone guidance |

## 5.3 Related Internal Documents (To Be Produced)

The following documents are anticipated as companions to this SRS but are outside the scope of the current document:

- System Architecture Design Document
- Database Schema Design Document
- API Specification Document
- UI/UX Design Specification and Wireframes
- Test Plan and Test Case Document

---

# 6. Overall Description

## 6.1 Product Overview

LullaByte is a self-contained yet cloud-connected software product consisting of a cross-platform mobile client, a backend service layer, an AI/ML inference subsystem, and cloud storage/synchronization infrastructure. It functions as a unified newborn care companion, combining interpretive AI capability (cry analysis, parenting assistant) with structured longitudinal record-keeping (feeding, sleep, diaper, health, growth, milestones, media).

The product is designed as a new, standalone system. It is not a modification of an existing legacy system, though it is expected to interoperate with external systems (e.g., cloud storage providers, push notification services) as described in Section 6.2.

## 6.2 System Context

LullaByte operates within the following contextual environment:

- **Primary client**: A mobile application used directly by parents and caregivers on personal smartphones/tablets.
- **Backend services**: A server-side application exposing secure APIs for authentication, data persistence, synchronization, and AI inference orchestration.
- **AI/ML subsystem**: A model-serving component responsible for cry classification and conversational assistant responses, invoked by the backend on behalf of the client.
- **Cloud data layer**: Remote structured storage (for records) and media storage (for photos/videos), used for backup and multi-device/multi-user synchronization.
- **Local data layer**: On-device structured storage enabling full offline operation, later reconciled with the cloud data layer.
- **Notification services**: External push notification infrastructure used to deliver reminders and alerts to client devices.

The relationship among these components is described further in Section 7 (Product Perspective).

## 6.3 Product Positioning

LullaByte is positioned as a **specialized, accessibility-first newborn care platform**, distinguished from general-purpose baby tracking applications by two core differentiators:

1. **AI-driven cry interpretation** made accessible to deaf parents through non-auditory feedback.
2. **Consolidation of the full newborn care lifecycle** (feeding, sleep, diaper, health, growth, milestones, media) into a single offline-capable, multi-caregiver platform, rather than a narrow single-purpose tool.

## 6.4 Major Product Capability Summary

At a high level, the product provides the following capability groups, each elaborated with full functional requirements in a later part of this document:

- AI Cry Analysis and Prediction History
- Baby Profile and Multi-Baby / Twin Management
- Feeding Management (Breastfeeding, Bottle, Formula, Solids)
- Sleep Tracking
- Diaper Tracking
- Vaccination Scheduling and Reminders
- Milestone Tracking
- Growth Record Tracking
- Media Gallery
- AI Parenting Assistant
- Notifications
- Offline Mode and Cloud Synchronization
- Multi-User Role-Based Family Sharing
- Reports and Analytics
- Search
- Settings and Accessibility Configuration

## 6.5 Operating Environment (Summary)

LullaByte is intended to operate as a mobile application on modern smartphone operating systems, communicating with a backend service over standard internet protocols, with full functional fallback to local-only operation when offline. Detailed technology constraints are addressed later in this document under System Constraints.

## 6.6 Design and Implementation Constraints (Summary)

The system is expected to be designed with the following constraints in mind, elaborated later in this document:

- Must support full offline operation for all core daily-use tracking features.
- Must support secure multi-user, multi-device access to shared baby data.
- Must be architected for scalability toward public app store distribution.
- Must adhere to accessibility-first design principles, particularly for deaf users.
- Must not present AI-generated content (cry predictions, assistant responses) as medical diagnosis.

## 6.7 Assumptions and Dependencies (Summary)

A complete list of assumptions and dependencies is provided later in this document. At the overall description level, it is assumed that:

- Users possess a compatible smartphone device capable of audio recording (for the Cry Analyzer) and internet connectivity (intermittently, for synchronization).
- Users are the parent, legal guardian, or authorized caregiver of the baby profile(s) they manage.
- Vaccination and milestone reference data reflect general pediatric guidance and may require regional customization.

---

# 7. Product Perspective

## 7.1 System Positioning

LullaByte is a **new, independent product** rather than a component of an existing system. However, it is designed to operate within a broader ecosystem of external services (cloud storage, notification delivery, AI model hosting) that it depends upon but does not control. This section describes the system's relationship to its environment and major internal subsystems.

## 7.2 High-Level System Composition

The LullaByte product is composed of the following major subsystems:

| Subsystem | Responsibility |
|---|---|
| Mobile Client Application | Primary user-facing interface; local data storage; offline operation; UI rendering; accessibility features |
| Backend API Service | Business logic, authentication, authorization, data validation, orchestration between client, database, and AI subsystem |
| AI Cry Analysis Engine | Audio classification into cry categories or non-cry categories, returning probability-based predictions |
| AI Parenting Assistant Engine | Conversational, informational response generation for parenting-related queries |
| Structured Database (Cloud) | Persistent storage of structured records (profiles, feeding logs, sleep logs, diaper logs, vaccinations, milestones, growth records) |
| Local Structured Database (On-Device) | Offline-first local persistence mirroring cloud schema, enabling full functionality without connectivity |
| Media Storage (Cloud) | Storage and delivery of photos and videos associated with gallery and milestone features |
| Synchronization Engine | Reconciliation of local and cloud data, conflict handling, and synchronization logging |
| Notification Service Integration | Delivery of push notifications for reminders, alerts, and sync status updates |
| Authentication and Access Control Layer | User identity verification and role-based permission enforcement across shared baby profiles |

## 7.3 System Interfaces (Conceptual)

At the product perspective level, LullaByte interfaces with the following categories of external systems (detailed external interface requirements are provided later in this document):

- **Cloud infrastructure provider** — for structured data persistence, authentication support, and file/media storage.
- **Push notification gateway** — for delivering reminders and alerts to mobile devices.
- **AI/ML model serving environment** — for executing cry classification and conversational assistant inference.
- **Device-level hardware interfaces** — microphone (audio recording for cry analysis), camera and media library (gallery), local storage (offline database), and vibration/haptic hardware (accessibility notifications).

## 7.4 User Interfaces (Conceptual)

The primary user interface is a mobile application interface designed around the following conceptual areas, each corresponding to a functional module elaborated later in this document:

- Authentication and onboarding screens (login, registration, baby/twin registration).
- A central dashboard summarizing recent activity across tracked modules.
- Dedicated tracking interfaces for cry analysis, feeding, sleep, and diaper logging.
- Dedicated management interfaces for vaccinations, milestones, growth records, and gallery.
- An AI assistant conversational interface.
- Reports and analytics views.
- Settings, including accessibility and family-sharing configuration.

Interface design is guided throughout by the accessibility-first principles defined in Section 6 and elaborated in the Accessibility Requirements section later in this document.

## 7.5 Memory, Storage, and Operational Constraints (Conceptual)

- The system must support meaningful local storage of structured records and media on-device to enable offline operation across extended periods without connectivity.
- The system must be designed such that local storage growth (e.g., accumulated logs, cached media) is manageable and does not degrade device performance over time.
- Cloud storage must be designed to scale per-user and per-baby, accommodating multi-year record retention as described in the Project Objectives.

## 7.6 Product Functions Relationship

The subsystems described above collectively enable the product functions summarized in Section 8. The relationship is such that:

- The **Mobile Client** provides the interaction surface for all product functions.
- The **Backend API Service** mediates all data operations and enforces business rules and access control.
- The **AI Cry Analysis** and **AI Parenting Assistant** engines provide the intelligence layer distinguishing LullaByte from conventional tracking applications.
- The **Synchronization Engine** ensures continuity of product functions between offline and online states.

---

# 8. Product Functions

## 8.1 Purpose of This Section

This section provides a high-level, summarized enumeration of the major functions the LullaByte system shall perform. Each function listed here is expanded into complete functional requirements (purpose, inputs, outputs, user actions, system behavior, validation rules, error handling, and success conditions) in the Functional Requirements section of this document.

## 8.2 Summary of Major Product Functions

| Function Group | Summary Description |
|---|---|
| **User Authentication & Registration** | Allow users to securely register, log in, recover access, and manage their account identity. |
| **Baby Profile Management** | Allow creation and management of one or more baby profiles, including twin/multiple-baby scenarios, with core identity and medical information. |
| **AI Cry Analyzer** | Allow recording or uploading of audio, classify the audio as a cry category or non-cry sound, display probability-based predictions and recommendations, and store prediction history. |
| **Feeding Tracker** | Allow logging and tracking of breastfeeding, bottle feeding, formula feeding, and solid feeding sessions, with automatic calculation of summary statistics. |
| **Sleep Tracker** | Allow logging of sleep sessions with start/end time, day/night classification, and quality indicators, with automatic aggregation into daily/weekly/monthly summaries. |
| **Diaper Tracker** | Allow logging of diaper change events with type, size, color, and notes, with timeline and daily statistics views. |
| **Vaccination Management** | Allow scheduling, tracking, and reminding of vaccinations, including status (upcoming, completed, pending, missed) and associated hospital/doctor/appointment data. |
| **Milestone Tracking** | Allow recording of developmental milestones against expected age ranges, with supporting photos, videos, and notes. |
| **Growth Tracking** | Allow recording of physical growth measurements over time, supporting trend visualization. |
| **Gallery** | Allow storage, automatic categorization, search, and cloud backup of baby-related photos and videos. |
| **AI Parenting Assistant** | Provide conversational, informational responses to parenting-related questions across feeding, sleep, vaccination, growth, and general care topics, without medical diagnosis. |
| **Notification System** | Deliver reminders, alerts, and synchronization status notifications through visual, haptic, and (where applicable) audio channels. |
| **Offline Mode** | Ensure full functionality of core tracking features without an internet connection, using local data storage. |
| **Cloud Synchronization** | Automatically reconcile local and cloud data when connectivity is available, maintaining synchronization logs. |
| **Multi-Baby and Twin Support** | Allow management of multiple, independently tracked baby profiles within a single family account, including simultaneous twin registration and tracking. |
| **Role-Based Access & Family Sharing** | Allow multiple users (parents, caregivers, family members) to access shared baby profiles according to assigned roles and permissions. |
| **Reports and Analytics** | Generate summarized, visualized insights from logged data across all tracking modules. |
| **Search** | Allow users to search across records, media, and history within the application. |
| **Settings** | Allow configuration of account, notification, accessibility, and family-sharing preferences. |

## 8.3 Function Interaction Overview

The functions summarized above are not isolated; several depend on shared data and infrastructure:

- **Baby Profile Management** underlies nearly all other functions, as feeding, sleep, diaper, vaccination, milestone, growth, and gallery data are all associated with a specific baby profile.
- **Offline Mode** and **Cloud Synchronization** operate as a cross-cutting concern affecting all data-producing functions (feeding, sleep, diaper, vaccination, milestone, growth, gallery, cry history).
- **Notification System** is invoked by multiple functions (vaccination reminders, feeding/sleep reminders, sync status, family-sharing invitations).
- **Role-Based Access & Family Sharing** governs which users may invoke which functions on a given baby profile.
- **Reports and Analytics** and **Search** operate as read/aggregation layers over data produced by the tracking functions.

## 8.4 Function Prioritization (MoSCoW Summary)

| Priority | Functions |
|---|---|
| **Must Have** | Authentication & Registration, Baby Profile Management, AI Cry Analyzer, Feeding Tracker, Sleep Tracker, Diaper Tracker, Offline Mode, Cloud Synchronization, Notifications, Role-Based Access & Family Sharing |
| **Should Have** | Vaccination Management, Milestone Tracking, Growth Tracking, Gallery, AI Parenting Assistant, Reports and Analytics, Search |
| **Could Have** | Advanced analytics visualizations, extended assistant conversational depth |
| **Future Scope** | Wearable/device integrations, hospital/EHR integrations (detailed later in this document) |

---

# 9. User Characteristics

## 9.1 Purpose of This Section

This section describes the characteristics of the intended users of the LullaByte system, including their technical proficiency, domain knowledge, accessibility needs, and usage context. These characteristics directly inform the usability and accessibility requirements elaborated later in this document.

## 9.2 Primary User Personas

### 9.2.1 Mother

- **Role**: Primary caregiver, typically the most frequent application user, especially for breastfeeding tracking.
- **Technical proficiency**: Varies widely; assumed to range from novice to intermediate smartphone users.
- **Context of use**: Frequently uses the application one-handed, often while feeding or holding the baby, during periods of sleep deprivation.
- **Key needs**: Fast, low-friction logging; minimal cognitive load; clear reminders; reassurance and guidance during a physically and emotionally demanding period.

### 9.2.2 Father

- **Role**: Primary or secondary caregiver, sharing responsibilities with the mother.
- **Technical proficiency**: Varies widely.
- **Context of use**: May use the application to log bottle feeding, diaper changes, and sleep, often coordinating with the mother or other caregivers via family sharing.
- **Key needs**: Real-time visibility into what other caregivers have already logged; simple coordination through shared profiles.

### 9.2.3 Caregiver (General, including Deaf Parents)

- **Role**: Any individual responsible for regular hands-on infant care, including deaf or hard-of-hearing parents as a specifically prioritized user group.
- **Technical proficiency**: Varies widely.
- **Accessibility needs**: For deaf caregivers specifically, all critical feedback (cry predictions, alerts, reminders) must be conveyed through visual and haptic channels rather than relying on audio. Interface language should be simple and minimally text-dependent, supported by icons and visual indicators.
- **Context of use**: Highly similar to mother/father personas, with the addition of accessibility-first interaction requirements.
- **Key needs**: Reliable, glanceable, non-auditory interpretation of infant cries; confidence in AI predictions; visual/haptic notification delivery.

## 9.3 Secondary User Personas

### 9.3.1 Pediatrician

- **Role**: Medical professional who may review growth, vaccination, and milestone data shared or exported by the family, typically outside the application itself in the initial release.
- **Technical proficiency**: Assumed competent with digital health information but not necessarily a regular application user.
- **Key needs**: Accurate, exportable, chronologically organized records; explicit distinction between parent-logged data and AI-generated suggestions (which must never be presented as diagnosis).

### 9.3.2 Grandparents

- **Role**: Occasional caregiver, potentially added as a family-sharing participant with limited role permissions.
- **Technical proficiency**: Assumed lower average smartphone proficiency; may require larger fonts, simpler navigation, and minimal interaction complexity.
- **Key needs**: Simple, low-complexity logging of basic activities (e.g., feeding, diaper) during periods of babysitting; visibility into baby's schedule and needs.

### 9.3.3 Babysitter

- **Role**: Temporary, non-family caregiver granted limited, time-bound or role-restricted access to a baby's profile.
- **Technical proficiency**: Assumed moderate smartphone proficiency.
- **Key needs**: Quick access to essential information (feeding schedule, allergies, medical notes) and the ability to log activity during their caregiving window, without access to sensitive account or family-management settings.

## 9.4 Future User Categories

The following user categories are identified as future users, relevant to long-term product direction and referenced in the Future Scope section later in this document:

- **Hospitals** — potential institutional users for postnatal care continuity.
- **Clinics** — potential institutional users for pediatric visit preparation and history review.
- **Childcare Centers** — potential institutional users requiring multi-child, multi-family tracking capability.

## 9.5 User Characteristics Summary Table

| User Type | Category | Technical Proficiency | Accessibility Considerations | Primary Usage Pattern |
|---|---|---|---|---|
| Mother | Primary | Novice–Intermediate | Standard, low-friction UX | High frequency, one-handed use |
| Father | Primary | Novice–Intermediate | Standard, low-friction UX | Moderate–high frequency |
| Caregiver (incl. Deaf Parents) | Primary | Novice–Intermediate | Visual/haptic-first, minimal text complexity | High frequency, accessibility-critical |
| Pediatrician | Secondary | Intermediate–Advanced (general digital literacy) | Clear data provenance (parent-logged vs. AI-suggested) | Low frequency, review-oriented |
| Grandparents | Secondary | Novice | Larger fonts, simplified navigation | Low–moderate frequency |
| Babysitter | Secondary | Intermediate | Restricted access scope | Time-bound, session-based |
| Hospitals / Clinics / Childcare Centers | Future | Institutional / Advanced | Multi-user, multi-child administrative needs | Future scope |

## 9.6 Implications for Design

The diversity of user proficiency and accessibility needs described above directly informs the following design principles, elaborated further in the Non-Functional and Accessibility Requirements sections of this document:

- The interface must minimize reliance on text-heavy explanations, favoring icons, color coding, and visual hierarchy.
- Critical information (cry predictions, alerts, reminders) must never depend solely on audio delivery.
- Role-based access must support graduated permission levels appropriate to primary, secondary, and temporary caregivers.
- Onboarding and daily-use flows must remain simple enough for low-technical-proficiency users (e.g., grandparents) while remaining efficient for high-frequency primary users operating under sleep deprivation and time pressure.

---

# 10. Functional Requirements

## 10.0 Section Conventions

Each functional module in this section is specified using the following structure: Purpose, Description, Inputs, Outputs, Preconditions, Postconditions, User Actions, System Behaviour, Validation Rules, Error Handling, and Success Conditions. Individual requirement statements are uniquely identified using the format defined in Section 1.4 (e.g., FR-AUTH-01). All requirements use **MUST/SHALL**, **SHOULD**, or **MAY** to indicate priority.

---

## 10.1 Authentication

### 10.1.1 User Registration

**Purpose**
To allow a new user to create a LullaByte account, establishing the identity required to access and manage baby profiles and associated data.

**Description**
Registration enables a new user to create an account using an email address and password, or via a supported third-party identity provider (see Google Sign-In, Section 10.1.3). Successful registration creates a user identity record and initiates onboarding toward parent and baby profile setup.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Full Name | Text | Yes |
| Email Address | Text (email format) | Yes |
| Password | Text (masked) | Yes |
| Confirm Password | Text (masked) | Yes |
| Phone Number | Text (optional at registration, required if using Phone OTP) | Conditional |
| Accepted Terms & Privacy Policy | Boolean (checkbox) | Yes |

**Outputs**

- Newly created user account record.
- Confirmation message/screen indicating successful registration.
- Verification email or OTP dispatched (if email/phone verification is enabled).
- Navigation to Parent Registration / onboarding flow.

**Preconditions**

- The application is installed and launched.
- The user does not already hold an account with the submitted email address.
- The device has network connectivity (registration requires backend account creation and cannot be completed fully offline).

**Postconditions**

- A new user account exists in the system in an "unverified" or "verified" state depending on verification configuration.
- The user is authenticated and holds a valid session, or is redirected to a verification step.

**User Actions**

1. User navigates to the Registration screen.
2. User enters full name, email, password, and confirms password.
3. User accepts Terms & Privacy Policy.
4. User submits the registration form.
5. User optionally completes email/phone verification if prompted.

**System Behaviour**

- The system SHALL validate all required fields client-side before submission.
- The system SHALL check email uniqueness against existing accounts.
- The system SHALL hash the password before storage (see Security Requirements, later in this document).
- The system SHALL create a new user account record upon successful validation.
- The system SHALL issue an authentication session/token upon successful registration.
- The system SHOULD send a verification email or OTP if verification is enabled.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-REG-01 | Full name must not be empty and must contain only valid name characters. |
| VR-REG-02 | Email must conform to standard email format. |
| VR-REG-03 | Email must not already be associated with an existing account. |
| VR-REG-04 | Password must be a minimum of 8 characters and include at least one uppercase letter, one lowercase letter, one digit, and one special character. |
| VR-REG-05 | Password and Confirm Password fields must match exactly. |
| VR-REG-06 | Terms & Privacy Policy acceptance checkbox must be checked before submission is allowed. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Email already registered | Display "An account with this email already exists" and suggest login or password reset. |
| Password does not meet complexity rules | Display inline validation message specifying unmet criteria. |
| Passwords do not match | Display "Passwords do not match" inline error. |
| Network unavailable during submission | Display "Registration requires an internet connection. Please try again when connected." |
| Terms not accepted | Disable submit action and display prompt to accept terms. |

**Success Conditions**

- Account record is created and persisted.
- User receives confirmation of successful registration.
- User is transitioned to Parent Registration / onboarding flow.

---

### 10.1.2 Login

**Purpose**
To authenticate a returning user and grant access to their account, baby profiles, and associated data.

**Description**
Login allows a registered user to access their account using email/password credentials, or via supported alternative methods (Google Sign-In, Phone OTP). Upon successful authentication, the system establishes a session and loads the user's associated baby profile(s).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Email Address | Text | Yes (for email/password login) |
| Password | Text (masked) | Yes (for email/password login) |

**Outputs**

- Authenticated session/token.
- Navigation to Dashboard (or onboarding, if no baby profile exists yet).
- Error message on failed authentication attempt.

**Preconditions**

- A registered and verified account exists for the submitted credentials.
- The device has network connectivity for initial authentication (subsequent app access MAY use a cached/offline session per Section 10.1.6).

**Postconditions**

- A valid session/token is issued and stored securely on-device.
- User's associated baby profile(s) and role permissions are loaded.

**User Actions**

1. User navigates to the Login screen.
2. User enters email and password (or selects an alternative sign-in method).
3. User submits the login form.

**System Behaviour**

- The system SHALL validate submitted credentials against stored account records.
- The system SHALL issue a session/authentication token upon successful validation.
- The system SHALL enforce account lockout or throttling after repeated failed login attempts (see Security Requirements).
- The system SHALL load associated baby profile(s), role, and permission data upon successful login.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-LOGIN-01 | Email and password fields must not be empty. |
| VR-LOGIN-02 | Email must conform to standard email format. |
| VR-LOGIN-03 | Credentials must match a stored, verified account record. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid email or password | Display generic "Invalid email or password" message (must not reveal which field is incorrect, for security). |
| Account not verified | Prompt user to complete verification, with option to resend verification email/OTP. |
| Repeated failed attempts | Temporarily lock login attempts and display cooldown message. |
| Network unavailable | Attempt offline session validation (Section 10.1.6); if unavailable, display "Unable to connect. Please check your internet connection." |

**Success Conditions**

- User is authenticated and a valid session is established.
- User is navigated to the Dashboard or appropriate onboarding step.

---

### 10.1.3 Google Sign-In

**Purpose**
To allow users to register or log in using their existing Google account, reducing friction in account creation and access.

**Description**
Google Sign-In allows the user to authenticate via Google's identity platform. On first use, this creates a new LullaByte account linked to the Google identity; on subsequent use, it authenticates the existing linked account.

**Inputs**

- User selection of "Sign in with Google" action.
- Google account credentials (handled entirely within Google's identity flow, not directly by LullaByte).

**Outputs**

- Authenticated session/token.
- Newly created or existing user account, linked to the Google identity.

**Preconditions**

- Device has network connectivity.
- User has a valid Google account.
- Google Sign-In service is reachable.

**Postconditions**

- A user account (new or existing) is linked to the Google identity and authenticated.

**User Actions**

1. User selects "Sign in with Google" on the Login or Registration screen.
2. User completes Google's account selection/consent flow.
3. User is returned to LullaByte, authenticated.

**System Behaviour**

- The system SHALL request the necessary identity token/profile information from Google upon user consent.
- The system SHALL check whether an existing account is linked to the returned Google identity.
- The system SHALL create a new account automatically if no linked account exists, pre-filling available profile information (e.g., name, email).
- The system SHALL issue a session/token upon successful authentication.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GSI-01 | The Google-provided email must be verified by Google before account creation/linking is permitted. |
| VR-GSI-02 | If the Google email matches an existing email/password account, the system SHOULD prompt the user to confirm account linking rather than silently merging accounts. |

**Error Handling**

| Scenario | System Response |
|---|---|
| User cancels Google consent flow | Return to Login/Registration screen with no error state persisted. |
| Google service unreachable | Display "Google Sign-In is currently unavailable. Please try again or use email login." |
| Email conflict with existing account | Prompt user to confirm linking or use alternate login method. |

**Success Conditions**

- User is authenticated via Google identity.
- Session is established and user is navigated to Dashboard or onboarding.

---

### 10.1.4 Phone OTP

**Purpose**
To allow users to register or log in using phone number verification via a One-Time Password (OTP), providing an alternative to email-based authentication.

**Description**
Phone OTP authentication sends a time-limited numeric code to the user's registered phone number via SMS. The user enters this code to verify ownership of the phone number and complete authentication.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Phone Number | Text (with country code) | Yes |
| OTP Code | Numeric (typically 4–6 digits) | Yes |

**Outputs**

- OTP dispatched via SMS.
- Authenticated session/token upon successful OTP verification.

**Preconditions**

- Device has network connectivity.
- User has entered a valid, reachable phone number.
- SMS delivery service is reachable.

**Postconditions**

- Phone number is verified and associated with the user account.
- A valid session/token is issued.

**User Actions**

1. User enters phone number and requests OTP.
2. User receives SMS containing OTP code.
3. User enters the OTP code into the application.
4. User submits for verification.

**System Behaviour**

- The system SHALL generate a time-limited, single-use OTP code upon request.
- The system SHALL dispatch the OTP via SMS to the provided phone number.
- The system SHALL validate the submitted OTP against the generated code and its expiry.
- The system SHALL issue a session/token upon successful OTP verification.
- The system SHALL invalidate the OTP after successful use or expiry.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-OTP-01 | Phone number must conform to a valid phone number format, including country code. |
| VR-OTP-02 | OTP must be numeric and match the expected length. |
| VR-OTP-03 | OTP must be submitted within its validity window (e.g., 5 minutes). |
| VR-OTP-04 | OTP requests must be rate-limited per phone number to prevent abuse. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid phone number format | Display inline validation error before allowing OTP request. |
| OTP expired | Display "Code expired. Please request a new one." with resend option. |
| Incorrect OTP entered | Display "Incorrect code. Please try again," with a limited number of retry attempts. |
| SMS delivery failure | Display "Unable to send code. Please check the number or try again later." |
| Excessive OTP requests | Temporarily block further requests and display cooldown message. |

**Success Conditions**

- OTP is verified successfully.
- Session is established and user is navigated to Dashboard or onboarding.

---

### 10.1.5 Password Reset

**Purpose**
To allow a user who has forgotten their password to securely regain access to their account.

**Description**
Password Reset allows a user to initiate a reset flow via their registered email (or phone number), receive a secure reset link or OTP, and set a new password.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Registered Email or Phone Number | Text | Yes |
| Reset Code / Link Token | Text | Yes (upon reset confirmation step) |
| New Password | Text (masked) | Yes |
| Confirm New Password | Text (masked) | Yes |

**Outputs**

- Password reset email or SMS dispatched.
- Confirmation of successful password change.

**Preconditions**

- An account exists for the submitted email/phone number.
- Device has network connectivity.

**Postconditions**

- The account's password is updated.
- All existing sessions for the account SHOULD be invalidated, requiring re-authentication with the new password.

**User Actions**

1. User selects "Forgot Password" on the Login screen.
2. User enters registered email or phone number.
3. User receives a reset link or OTP.
4. User enters the reset code (or follows the link) and sets a new password.
5. User confirms the new password and submits.

**System Behaviour**

- The system SHALL verify the existence of an account matching the submitted email/phone number without revealing account existence explicitly (to prevent enumeration).
- The system SHALL generate a time-limited, single-use reset token or OTP.
- The system SHALL validate the new password against the same complexity rules as registration (VR-REG-04).
- The system SHALL update the stored password hash upon successful validation.
- The system SHOULD invalidate all other active sessions upon password change.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PR-01 | Reset token/OTP must be valid and unexpired. |
| VR-PR-02 | New password must meet the same complexity requirements as VR-REG-04. |
| VR-PR-03 | New Password and Confirm New Password must match. |
| VR-PR-04 | New password must not be identical to the previous password. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Email/phone not associated with an account | Display a neutral message such as "If an account exists, a reset link has been sent" (to avoid account enumeration). |
| Reset token/OTP expired or invalid | Display "This reset link/code is no longer valid. Please request a new one." |
| New password fails complexity rules | Display inline validation detailing unmet requirements. |
| Passwords do not match | Display "Passwords do not match" inline error. |

**Success Conditions**

- Password is successfully updated.
- User is able to log in using the new password.
- User receives confirmation of the password change.

---

### 10.1.6 Session Management

**Purpose**
To maintain a secure, persistent authentication state for the user across app usage sessions, including support for offline access.

**Description**
Session Management governs how a user's authenticated state is created, stored, refreshed, validated, and terminated, including behavior when the device is offline and when a user explicitly logs out.

**Inputs**

- Authentication token issued at login/registration.
- Device state (online/offline).
- User logout action.

**Outputs**

- Maintained or terminated authenticated session state.
- Automatic session refresh (when online).
- Cached offline session validity (when offline).

**Preconditions**

- User has successfully authenticated at least once on the device.

**Postconditions**

- Session remains valid until explicit logout, token expiry without refresh, or security-triggered invalidation (e.g., password reset).

**User Actions**

1. User continues using the app across multiple visits without re-entering credentials (while session is valid).
2. User explicitly logs out from Settings.
3. User's session expires or is invalidated, prompting re-authentication.

**System Behaviour**

- The system SHALL securely store the authentication token on-device (see Security Requirements).
- The system SHALL automatically refresh the session token when online and nearing expiry.
- The system SHALL allow continued access to locally cached data and core offline-capable features when the device is offline, even if the session token cannot be refreshed, up to a defined offline grace period.
- The system SHALL require re-authentication once the offline grace period is exceeded or the token is invalidated.
- The system SHALL terminate the session and clear locally cached authentication credentials upon explicit logout.
- The system SHALL invalidate active sessions upon password reset (see VR-PR discussion in Section 10.1.5).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SESS-01 | Session tokens must have a defined expiry and refresh mechanism. |
| VR-SESS-02 | Offline access must be bounded by a maximum grace period, after which re-authentication is required upon reconnection. |
| VR-SESS-03 | Logout must fully clear locally stored session credentials. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Token expired while online | Attempt silent refresh; if refresh fails, redirect to Login with session-expired message. |
| Token expired while offline | Permit continued offline access within grace period; queue re-authentication prompt for next successful connection. |
| Session invalidated remotely (e.g., password reset on another device) | On next connection, force logout and prompt re-authentication. |

**Success Conditions**

- User maintains uninterrupted access across normal usage patterns, online and offline, within defined session and grace-period rules.
- Logout and forced invalidation scenarios reliably terminate access and clear credentials.

---

## 10.2 Parent Registration

**Purpose**
To capture structured information about the parent(s)/primary account holder(s), establishing their role in relation to the baby profile(s) they will manage.

**Description**
Parent Registration follows initial account creation (Section 10.1.1) and precedes Baby Registration. It captures the parent's relationship role (e.g., Mother, Father, Guardian, Caregiver) and any accessibility preferences relevant to their use of the application (e.g., identifying as a deaf or hard-of-hearing user, to proactively configure accessibility settings described later in this document).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Relationship Role | Selection (Mother / Father / Guardian / Caregiver / Other) | Yes |
| Display Name | Text | Yes |
| Accessibility Preference (e.g., Deaf/Hard-of-Hearing) | Selection/Toggle | No |
| Contact Email/Phone (confirmation of Section 10.1 data) | Text | Pre-filled |

**Outputs**

- Parent profile record linked to the authenticated user account.
- Pre-configured accessibility settings, if selected.
- Navigation to Baby Registration flow.

**Preconditions**

- User has successfully completed account registration/authentication (Section 10.1).

**Postconditions**

- A parent profile record exists, linked to the user account, with role and accessibility preference stored.

**User Actions**

1. User selects their relationship role.
2. User confirms or edits display name.
3. User optionally indicates accessibility preferences.
4. User submits to proceed to Baby Registration.

**System Behaviour**

- The system SHALL create a parent profile record associated with the authenticated user account.
- The system SHALL apply selected accessibility preferences to default application settings immediately (e.g., enabling visual/haptic-first notification defaults).
- The system SHALL treat the first registered parent on a new account as the default primary account owner, with full role permissions (see Role-Based Access, addressed later in this document).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PREG-01 | Relationship Role must be selected from the defined set of values. |
| VR-PREG-02 | Display Name must not be empty. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Relationship Role not selected | Prevent progression and display inline prompt to select a role. |
| Network unavailable | Allow parent profile data to be stored locally and synchronized once connectivity is available (consistent with Offline Mode requirements addressed later in this document). |

**Success Conditions**

- Parent profile is successfully created and linked to the user account.
- User is navigated to Baby Registration.

---

## 10.3 Baby Registration

### 10.3.1 Baby Details

**Purpose**
To capture the core identifying information of a baby profile.

**Description**
Baby Details capture the foundational identity data required to create a baby profile, which subsequently anchors all tracking modules (feeding, sleep, diaper, vaccination, milestones, growth, gallery, cry history).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Baby Name | Text | Yes |
| Gender | Selection (Male / Female / Other / Prefer not to say) | Yes |
| Profile Photo | Image | No |
| Nickname | Text | No |

**Outputs**

- New baby profile record (in draft state until Birth Information and Medical Information steps are also completed, or saved incrementally per system design).

**Preconditions**

- Parent Registration (Section 10.2) has been completed.

**Postconditions**

- A baby profile record is created and associated with the parent account, pending completion of Birth and Medical Information.

**User Actions**

1. User enters baby name and selects gender.
2. User optionally uploads a profile photo and enters a nickname.
3. User proceeds to Birth Information.

**System Behaviour**

- The system SHALL create a new baby profile record scoped to the parent account/family.
- The system SHALL generate a unique baby profile identifier.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BD-01 | Baby Name must not be empty. |
| VR-BD-02 | Gender must be selected from the defined set of values. |
| VR-BD-03 | Profile Photo, if provided, must conform to supported image formats and a maximum file size limit. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Baby Name empty | Prevent progression; display inline validation error. |
| Unsupported photo format/size | Display error message specifying supported formats and size limit; allow retry or skip. |

**Success Conditions**

- Baby profile record is created with valid core identity data.

---

### 10.3.2 Birth Information

**Purpose**
To capture birth-related data points that anchor growth tracking, milestone expected-age calculations, and vaccination scheduling.

**Description**
Birth Information records the baby's birth date, time, weight, and height, which serve as baseline reference points for subsequent growth tracking and age-based feature calculations (e.g., milestone expected-age comparisons, vaccination due-date scheduling).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Birth Date | Date | Yes |
| Birth Time | Time | No |
| Birth Weight | Numeric (kg or lb, configurable unit) | Yes |
| Birth Height/Length | Numeric (cm or in, configurable unit) | Yes |

**Outputs**

- Birth Information stored as part of the baby profile record.
- Baseline entry automatically created in Growth Records (see Growth Tracking, addressed in a later part of this document).
- Baby's current age (derived) becomes available for use across the application (dashboard, milestones, vaccination scheduling).

**Preconditions**

- Baby Details (Section 10.3.1) has been entered.

**Postconditions**

- Birth Information is persisted as part of the baby profile.
- Derived age calculations become available system-wide for this baby profile.

**User Actions**

1. User enters birth date (and optionally time).
2. User enters birth weight and height/length.
3. User submits to proceed to Medical Information.

**System Behaviour**

- The system SHALL store birth date, time, weight, and height as part of the baby profile.
- The system SHALL automatically create an initial Growth Record entry using the birth weight and height/length.
- The system SHALL compute and make available the baby's current age (in days/weeks/months/years as contextually appropriate) derived from the birth date.
- The system SHALL NOT accept a birth date in the future.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BI-01 | Birth Date must not be empty and must not be a future date. |
| VR-BI-02 | Birth Weight must be a positive numeric value within a plausible physiological range. |
| VR-BI-03 | Birth Height/Length must be a positive numeric value within a plausible physiological range. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Birth Date in the future | Display "Birth date cannot be in the future" and prevent submission. |
| Birth Weight/Height outside plausible range | Display inline warning and request confirmation before allowing submission (to accommodate legitimate edge cases while catching likely data-entry errors). |
| Required field missing | Prevent progression; display inline validation error. |

**Success Conditions**

- Birth Information is successfully stored.
- Initial Growth Record baseline is created.
- Derived baby age becomes available throughout the application.

---

### 10.3.3 Medical Information

**Purpose**
To capture baseline medical information relevant to the baby's ongoing care, including care providers, blood group, and known allergies.

**Description**
Medical Information records optional but clinically relevant details that support informed caregiving and are referenced by the AI Parenting Assistant (for contextual, non-diagnostic guidance) and by caregivers reviewing the profile (e.g., babysitters needing allergy information).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Blood Group | Selection | No |
| Doctor Name | Text | No |
| Hospital/Clinic Name | Text | No |
| Known Allergies | Text / Multi-entry list | No |
| Medical Notes | Text (long-form) | No |

**Outputs**

- Medical Information stored as part of the baby profile record.
- Allergy information surfaced contextually where relevant (e.g., feeding module warnings, babysitter view).

**Preconditions**

- Birth Information (Section 10.3.2) has been entered.

**Postconditions**

- Medical Information is persisted as part of the baby profile.
- Baby Registration flow is considered complete; user is navigated to the Dashboard.

**User Actions**

1. User optionally enters blood group, doctor, hospital/clinic, allergies, and medical notes.
2. User submits to complete Baby Registration.

**System Behaviour**

- The system SHALL store all provided medical information as part of the baby profile.
- The system SHALL allow this step to be skipped and completed later via Baby Profile editing (see Baby Profile Requirements, addressed in a later part of this document), given the non-mandatory nature of these fields.
- The system SHOULD surface known allergy information contextually within relevant modules (e.g., feeding).
- Upon completion (or skip), the system SHALL mark Baby Registration as complete and navigate the user to the Dashboard.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MI-01 | If provided, Medical Notes must not exceed the defined maximum character length. |
| VR-MI-02 | Allergy entries, if provided, must be non-empty text values. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Medical Notes exceeds character limit | Display character count and prevent submission until within limit. |
| Network unavailable | Store data locally and synchronize once connectivity is available. |

**Success Conditions**

- Medical Information is successfully stored (or explicitly skipped).
- Baby Registration is marked complete.
- User is navigated to the Dashboard with a fully initialized baby profile.

---

## 10.4 Twin Baby Registration

### 10.4.1 Twin Detection

**Purpose**
To identify, at the point of Baby Registration, that the parent is registering multiple babies from the same birth event (twins or higher-order multiples), enabling a streamlined multi-profile registration flow.

**Description**
Twin Detection presents the user with an explicit choice during Baby Registration to indicate multiple births, triggering a modified registration flow that pre-links the resulting baby profiles as siblings from the same birth event while still capturing each baby's individually distinct data.

**Inputs**

- User selection: "Registering a single baby" vs. "Registering twins/multiples."
- Number of babies (if multiples selected), e.g., 2 for twins.

**Outputs**

- Registration flow branches into repeated Baby Details/Birth Information/Medical Information steps, one per baby, with shared birth event context (e.g., same Birth Date pre-filled, individually editable).

**Preconditions**

- Parent Registration (Section 10.2) has been completed.

**Postconditions**

- The system is configured to create multiple, separately identified baby profiles, flagged as linked multiples.

**User Actions**

1. At the start of Baby Registration, user selects "Twins/Multiples."
2. User specifies the number of babies being registered.
3. User proceeds through Baby Details, Birth Information, and Medical Information for each baby individually.

**System Behaviour**

- The system SHALL present a clear choice between single-baby and multiple-baby (twin) registration before collecting baby-specific details.
- The system SHALL, upon multiples selection, repeat the Baby Details/Birth Information/Medical Information steps once per baby.
- The system SHALL pre-fill shared birth-event fields (e.g., Birth Date) across linked profiles by default, while allowing individual override (e.g., differing birth times or weights).
- The system SHALL tag all babies registered within the same multiples flow with a shared "multiple birth group" identifier.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-TD-01 | Number of babies for multiples registration must be at least 2. |
| VR-TD-02 | Each baby within the multiples group must have a distinct Baby Name. |

**Error Handling**

| Scenario | System Response |
|---|---|
| User enters fewer than 2 for multiples count | Display validation error and prevent progression. |
| Duplicate baby names within the same multiples group | Display warning and request confirmation or distinct naming (e.g., to avoid ambiguity in lists and notifications). |

**Success Conditions**

- Twin/multiples registration path is correctly triggered and the appropriate number of baby profile flows are presented.

---

### 10.4.2 Separate Baby Profiles

**Purpose**
To ensure each baby in a multiple-birth registration is represented as a fully independent, individually trackable profile.

**Description**
Although linked by a shared "multiple birth group" identifier for contextual convenience, each baby registered via the twin/multiples flow must have entirely independent records across all tracking modules (feeding, sleep, diaper, vaccination, milestones, growth, gallery, cry history).

**Inputs**

- Individually completed Baby Details, Birth Information, and Medical Information for each baby (Section 10.3).

**Outputs**

- Independent baby profile records, each with its own unique identifier, linked by a shared multiple-birth-group reference.

**Preconditions**

- Twin Detection (Section 10.4.1) has been triggered and per-baby details have been submitted.

**Postconditions**

- Each baby has a fully independent profile record, distinct identifier, and independent data namespace for all tracking modules.

**User Actions**

- No additional user action beyond completing per-baby registration steps (Section 10.3, repeated per baby).

**System Behaviour**

- The system SHALL assign each baby in a multiples group a unique baby profile identifier, independent of siblings.
- The system SHALL ensure all subsequent tracking data (feeding, sleep, diaper, etc.) is stored against the specific baby's identifier, never shared or merged with a sibling's data.
- The system SHALL retain the shared multiple-birth-group reference solely for contextual UI grouping (e.g., "Twins: Baby A & Baby B" grouping on selection screens), not for data storage merging.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SBP-01 | Each baby profile identifier within a multiples group must be unique. |
| VR-SBP-02 | No tracking record (feeding, sleep, diaper, vaccination, milestone, growth, gallery, cry history) may reference more than one baby profile identifier. |

**Error Handling**

| Scenario | System Response |
|---|---|
| System failure during multi-profile creation (e.g., one profile fails to save) | Roll back or flag incomplete multiples registration and prompt user to retry the failed profile without duplicating successfully created ones. |

**Success Conditions**

- Each baby in a multiples registration has a fully independent, correctly isolated profile and data namespace.

---

### 10.4.3 Baby Switching

**Purpose**
To allow a user managing multiple baby profiles (including but not limited to twins) to easily switch the active baby context throughout the application.

**Description**
Baby Switching provides a persistent, accessible mechanism (e.g., a profile selector on the Dashboard) allowing the user to change which baby's data is currently being viewed or logged, across all tracking modules.

**Inputs**

- User selection of a baby profile from the available list associated with their account.

**Outputs**

- Application context (Dashboard, tracking modules, reports) updates to reflect the selected baby's data.

**Preconditions**

- User account has two or more associated baby profiles.

**Postconditions**

- The application's active baby context is updated and persisted as the default for the current session (and optionally remembered across sessions).

**User Actions**

1. User taps the baby profile selector (e.g., from the Dashboard header).
2. User selects a different baby profile from the list.
3. Application updates all relevant views to reflect the newly selected baby.

**System Behaviour**

- The system SHALL provide a persistent, easily accessible UI control for switching between associated baby profiles when more than one exists.
- The system SHALL update all data views (Dashboard, tracking modules, reports, gallery) to reflect the newly selected baby profile immediately upon switching.
- The system SHALL visually distinguish which baby profile is currently active at all times (e.g., name/photo displayed persistently).
- The system SHOULD remember the last-active baby profile across app sessions for user convenience.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BSW-01 | The system must only allow switching among baby profiles the authenticated user has permitted role-based access to. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Selected baby profile becomes inaccessible (e.g., access revoked mid-session) | Display appropriate access-denied message and revert to another accessible profile, if available. |

**Success Conditions**

- User can reliably and quickly switch active baby context, with all views accurately reflecting the selected baby's data.

---

### 10.4.4 Data Separation

**Purpose**
To guarantee strict logical isolation of each baby's data, preventing any cross-contamination between siblings (twins/multiples) or between unrelated baby profiles.

**Description**
Data Separation is a cross-cutting requirement ensuring that every data-producing module in the system (cry history, feeding, sleep, diaper, vaccination, milestones, growth, gallery, notifications, reports) strictly scopes all records to a single baby profile identifier, with no aggregation or leakage across profiles unless explicitly and intentionally presented as a combined, opt-in view (e.g., a "family reports" view spanning multiple babies).

**Inputs**

- All data-producing actions across tracking modules, each associated with an active baby profile context (Section 10.4.3).

**Outputs**

- Correctly isolated data records per baby profile.

**Preconditions**

- One or more baby profiles exist under the user's account.

**Postconditions**

- All records remain correctly scoped to their originating baby profile at all times.

**User Actions**

- Implicit; enforced automatically as users log data against the currently active baby profile (Section 10.4.3).

**System Behaviour**

- The system SHALL associate every record created in any tracking module with exactly one baby profile identifier at the point of creation.
- The system SHALL enforce baby-profile scoping at the data access layer (not solely at the UI layer), such that queries for one baby's data cannot inadvertently return another baby's records.
- The system SHALL apply this separation uniformly regardless of whether babies are linked via a multiple-birth-group (twins) or are entirely unrelated (e.g., siblings of different ages, or babies under different family accounts via family sharing).
- The system MAY provide explicit, opt-in aggregate views (e.g., combined reports across twins) as a distinct, clearly labeled feature, without altering the underlying per-baby data isolation.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DS-01 | Every tracking record must contain a non-null, valid reference to exactly one baby profile identifier. |
| VR-DS-02 | Data access queries must always be filtered by baby profile identifier and user access permission; unscoped queries returning multi-baby data are not permitted outside explicitly designed aggregate features. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Attempted access to a record without proper baby-profile scoping/permission | Deny access and log the access attempt for security review (see Security Requirements, addressed later in this document). |

**Success Conditions**

- At all times, each baby profile's data remains fully and correctly isolated, verified through consistent scoping across all modules.

---

## 10.5 Dashboard

### 10.5.1 Dashboard Overview

**Purpose**
To provide users with a single, at-a-glance summary screen consolidating the most relevant and time-sensitive information about the currently active baby.

**Description**
The Dashboard is the primary landing screen after login, presenting a consolidated view of recent activity, upcoming reminders, and quick access to core tracking actions, tailored to the currently active baby profile (Section 10.4.3).

**Inputs**

- Currently active baby profile context.
- Aggregated data from all tracking modules (feeding, sleep, diaper, cry history, vaccination, milestones, growth).

**Outputs**

- Rendered Dashboard view containing Daily Summary, Quick Actions, Recent Activities, Statistics, and Navigation elements (Sections 10.5.2–10.5.6).

**Preconditions**

- User is authenticated.
- At least one baby profile exists and is set as active.

**Postconditions**

- User has visibility into current baby status and can initiate any core tracking or navigation action directly from this screen.

**User Actions**

1. User logs in or opens the app with an existing session.
2. User views the Dashboard as the default landing screen.
3. User interacts with any Dashboard element to navigate deeper or log new activity.

**System Behaviour**

- The system SHALL render the Dashboard as the default post-authentication screen when at least one baby profile exists.
- The system SHALL populate the Dashboard using the most current available data, whether from local offline storage or synchronized cloud data.
- The system SHALL refresh Dashboard data automatically when new activity is logged during the session.
- If no baby profile exists yet, the system SHALL redirect the user to Baby Registration (Section 10.3) instead of the Dashboard.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DASH-01 | Dashboard must not render tracking data belonging to a baby profile other than the currently active one. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No data yet logged for a newly created baby | Display friendly empty-state guidance encouraging the user to log their first activity. |
| Data fails to load (e.g., local DB error) | Display a non-blocking error state for the affected section while allowing other Dashboard sections to render normally. |

**Success Conditions**

- Dashboard renders accurately and promptly, reflecting the current state of the active baby's data.

---

### 10.5.2 Daily Summary

**Purpose**
To give users a condensed view of the current day's logged activity across core tracking modules.

**Description**
The Daily Summary presents counts and key figures for the current day, such as number of feedings, total sleep duration, number of diaper changes, and any cry analyses performed, updating in real time as new entries are logged.

**Inputs**

- Today's logged records across Feeding, Sleep, Diaper, and Cry Analyzer modules for the active baby.

**Outputs**

- Summary tiles/cards showing counts and totals for the current day (e.g., "5 Feedings," "3h 20m Sleep," "4 Diaper Changes").

**Preconditions**

- Dashboard Overview (Section 10.5.1) is rendered.

**Postconditions**

- User has an accurate, current-day snapshot without needing to navigate into individual modules.

**User Actions**

1. User views Daily Summary tiles on the Dashboard.
2. User taps a summary tile to navigate to the corresponding module's detailed view.

**System Behaviour**

- The system SHALL calculate Daily Summary values based on the local device's current date/timezone.
- The system SHALL update Daily Summary values immediately upon logging any new relevant activity during the session.
- The system SHALL reset Daily Summary calculations at the start of each new calendar day.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DSUM-01 | Daily Summary figures must only include records timestamped within the current calendar day for the active baby. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No activity logged yet today | Display zero-state values (e.g., "0 Feedings") rather than omitting the tile. |

**Success Conditions**

- Daily Summary accurately reflects same-day logged activity at all times during use.

---

### 10.5.3 Quick Actions

**Purpose**
To enable users to log common activities (feeding, sleep, diaper, cry analysis) with minimal navigation, directly from the Dashboard.

**Description**
Quick Actions present prominent, easily tappable shortcuts for the most frequently performed logging actions, reducing the number of steps required during high-frequency, time-pressured caregiving moments.

**Inputs**

- User tap on a Quick Action control (e.g., "Log Feeding," "Log Diaper," "Start Sleep Timer," "Analyze Cry").

**Outputs**

- Direct navigation to (or in-place display of) the corresponding quick-entry form for the selected action.

**Preconditions**

- Dashboard Overview (Section 10.5.1) is rendered.

**Postconditions**

- A new record is created in the corresponding tracking module, or the user is placed directly into the relevant entry flow.

**User Actions**

1. User taps a Quick Action control.
2. User completes the minimal required entry (e.g., diaper type) or is taken to the full entry form.
3. User confirms/saves the entry.

**System Behaviour**

- The system SHALL present Quick Action controls for, at minimum, Feeding, Sleep, Diaper, and Cry Analyzer.
- The system SHALL minimize the number of taps/fields required to complete a Quick Action entry, using smart defaults (e.g., current time pre-filled).
- The system SHALL immediately reflect any Quick Action entry in the Daily Summary (Section 10.5.2) and Recent Activities (Section 10.5.4).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-QA-01 | Quick Action entries must satisfy the same validation rules as their corresponding full module entry (see respective module functional requirements). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Required field missing in quick-entry form | Display inline validation error consistent with the full module's error handling. |

**Success Conditions**

- User can complete a common logging action from the Dashboard in significantly fewer steps than navigating to the full module.

---

### 10.5.4 Recent Activities

**Purpose**
To provide a reverse-chronological feed of recently logged activities across all tracking modules for the active baby.

**Description**
Recent Activities presents a unified, scrollable timeline combining entries from Feeding, Sleep, Diaper, Cry Analyzer, Vaccination, and Milestones, allowing users to quickly review what has happened recently without navigating to each module individually.

**Inputs**

- Recently created/updated records across all tracking modules for the active baby.

**Outputs**

- A chronologically ordered list of recent activity entries, each indicating module type, summary detail, and timestamp.

**Preconditions**

- Dashboard Overview (Section 10.5.1) is rendered.

**Postconditions**

- User has visibility into the most recent caregiving events without additional navigation.

**User Actions**

1. User scrolls the Recent Activities feed on the Dashboard.
2. User taps an individual activity entry to view or edit its full detail.

**System Behaviour**

- The system SHALL display Recent Activities in reverse-chronological order (most recent first).
- The system SHALL limit the default Dashboard view to a reasonable number of recent entries (e.g., most recent 10–20), with an option to view full history per module.
- The system SHALL update the Recent Activities feed immediately upon creation of any new record during the session.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-RA-01 | Recent Activities must only display records belonging to the currently active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No activities logged yet | Display empty-state guidance prompting the user to begin logging. |

**Success Conditions**

- Recent Activities accurately and promptly reflects the latest logged events across all modules.

---

### 10.5.5 Statistics

**Purpose**
To surface high-value, at-a-glance statistical indicators on the Dashboard, offering trend awareness without requiring navigation into the full Reports and Analytics module.

**Description**
Statistics present condensed indicators such as current growth percentile trend, days since last vaccination, average sleep duration over the past week, and similar summary metrics, drawing from the same underlying data used by the full Reports and Analytics module (addressed in a later part of this document).

**Inputs**

- Aggregated historical data across Feeding, Sleep, Diaper, Growth, and Vaccination modules for the active baby.

**Outputs**

- A set of concise statistical indicator cards/widgets on the Dashboard.

**Preconditions**

- Dashboard Overview (Section 10.5.1) is rendered.
- Sufficient historical data exists to compute meaningful statistics (otherwise, an appropriate empty/insufficient-data state is shown).

**Postconditions**

- User gains quick trend awareness directly from the Dashboard.

**User Actions**

1. User views Statistics widgets on the Dashboard.
2. User taps a Statistics widget to navigate to the corresponding detailed Reports and Analytics view.

**System Behaviour**

- The system SHALL compute Dashboard Statistics using the same underlying aggregation logic as the Reports and Analytics module to ensure consistency.
- The system SHALL indicate clearly when insufficient data exists to compute a meaningful statistic (e.g., "Not enough data yet").
- The system SHALL update Statistics values on a reasonable refresh cadence (e.g., on Dashboard load and after new relevant entries are logged).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-STAT-01 | Statistics must only be computed from data belonging to the currently active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient historical data | Display "Not enough data yet" state rather than a misleading or zero-filled statistic. |

**Success Conditions**

- Statistics widgets accurately reflect current trends and are consistent with the full Reports and Analytics module.

---

### 10.5.6 Navigation

**Purpose**
To provide clear, accessible, and consistent navigation from the Dashboard to all major modules of the application.

**Description**
Navigation defines the primary wayfinding structure of the application, anchored at the Dashboard, allowing users to reach every major functional module (Cry Analyzer, Feeding, Sleep, Diaper, Vaccination, Milestones, Growth, Gallery, AI Assistant, Reports, Search, Settings) consistently and predictably.

**Inputs**

- User taps/selections on navigation elements (e.g., bottom navigation bar, menu, module shortcuts).

**Outputs**

- Transition to the selected module's screen, preserving the currently active baby profile context.

**Preconditions**

- Dashboard Overview (Section 10.5.1) is rendered.

**Postconditions**

- User is placed within the selected module, with the active baby profile context preserved.

**User Actions**

1. User selects a navigation element (e.g., bottom navigation icon, menu item).
2. Application transitions to the corresponding module screen.

**System Behaviour**

- The system SHALL provide a persistent, accessible primary navigation structure (e.g., bottom navigation bar) exposing the most frequently used modules directly.
- The system SHALL provide a secondary navigation surface (e.g., menu or "More" section) for less frequently accessed modules, ensuring all modules remain reachable within a small, consistent number of taps.
- The system SHALL preserve the active baby profile context across all navigation transitions.
- The system SHALL visually indicate the currently active navigation section/module.
- The system SHALL apply accessibility-first design to navigation elements (large tap targets, clear icons, minimal text complexity), consistent with the accessibility principles established in Section 9.6 and elaborated in the Accessibility Requirements section later in this document.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-NAV-01 | Every major functional module defined in the System Scope must be reachable from the Dashboard within a maximum of two navigation actions. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Navigation target module fails to load | Display a non-blocking error state within the target screen and provide a retry action, without breaking the overall navigation shell. |

**Success Conditions**

- Users can reliably and predictably navigate to every major module from the Dashboard.
- Active baby profile context is never lost during navigation.

---

## 10.6 AI Cry Analyzer

### 10.6.1 Live Recording

**Purpose**
To allow a user to capture a live audio recording of a baby's cry directly within the application for AI analysis.

**Description**
Live Recording provides an in-app microphone-based recording interface, allowing the user to capture a cry episode as it occurs, with a visible recording indicator and control over start/stop.

**Inputs**
- User-initiated start/stop recording action.
- Live microphone audio stream.

**Outputs**
- A saved audio file (temporary or persisted) representing the recorded cry episode, with duration and timestamp metadata.

**Preconditions**
- Microphone permission has been granted by the user.
- An active baby profile is selected.

**Postconditions**
- A recorded audio clip is available for AI Prediction (Section 10.6.8) or discard.

**User Actions**
1. User navigates to the Cry Analyzer module.
2. User taps "Record."
3. User taps "Stop" to end recording (or recording auto-stops at maximum duration).
4. User chooses to submit the recording for analysis or discard/re-record.

**System Behaviour**
- The system SHALL request microphone permission if not already granted, and SHALL clearly explain the purpose of the request.
- The system SHALL display a visible, accessible (visual, not solely auditory) recording-in-progress indicator, including elapsed time.
- The system SHALL enforce a minimum and maximum recording duration.
- The system SHALL enforce a maximum recording duration and auto-stop recording upon reaching it.
- The system SHALL allow the user to discard and re-record before submitting for analysis.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYREC-01 | Recording duration must meet a minimum threshold (e.g., 3 seconds) before submission is permitted. |
| VR-CRYREC-02 | Recording duration must not exceed a defined maximum (e.g., 60 seconds); recording auto-stops at this limit. |
| VR-CRYREC-03 | Microphone permission must be granted before recording can begin. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Microphone permission denied | Display accessible (visual) explanation of why permission is needed and link to device settings. |
| Recording below minimum duration | Disable submission and display "Recording too short" message. |
| Microphone hardware/access failure | Display error state with retry option. |

**Success Conditions**
- A valid audio recording meeting duration requirements is captured and made available for AI Prediction or Upload flow continuation.

---

### 10.6.2 Upload Audio

**Purpose**
To allow a user to submit a pre-recorded audio file (e.g., captured by another device or app) for AI cry analysis, as an alternative to Live Recording.

**Description**
Upload Audio allows the user to select an existing audio file from device storage for submission to the Cry Analyzer pipeline, subject to the same downstream validation, detection, and prediction steps as a live recording.

**Inputs**
- User-selected audio file from device storage.

**Outputs**
- A validated audio file staged for AI Prediction (Section 10.6.8).

**Preconditions**
- File storage access permission has been granted.
- An active baby profile is selected.

**Postconditions**
- Selected audio file is available for AI Prediction or discard.

**User Actions**
1. User navigates to the Cry Analyzer module.
2. User taps "Upload Audio."
3. User selects a file from device storage.
4. User confirms submission for analysis.

**System Behaviour**
- The system SHALL request storage/file access permission if not already granted.
- The system SHALL restrict selectable files to supported audio formats (see Section 10.6.3).
- The system SHALL route the uploaded file through the same Audio Validation, Baby Cry Detection, Noise Reduction, Feature Extraction, and AI Prediction pipeline as Live Recording.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYUP-01 | Uploaded file must be in a supported audio format (see VR-CRYVAL-01). |
| VR-CRYUP-02 | Uploaded file size must not exceed the defined maximum limit. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Unsupported file format selected | Display "Unsupported file format" with list of accepted formats. |
| File exceeds size limit | Display "File too large" message specifying the maximum allowed size. |
| Storage permission denied | Display accessible explanation and link to device settings. |

**Success Conditions**
- A valid audio file is successfully selected and staged for analysis.

---

### 10.6.3 Audio Validation

**Purpose**
To verify that a submitted audio input (live-recorded or uploaded) meets the technical requirements necessary for reliable AI analysis before further processing.

**Description**
Audio Validation performs format, duration, size, and basic quality checks (e.g., silence/near-silence detection) on the submitted audio prior to passing it into the detection and prediction pipeline.

**Inputs**
- Submitted audio file (from Live Recording or Upload Audio).

**Outputs**
- Validation pass/fail result, with the audio file passed forward to Baby Cry Detection (Section 10.6.4) upon success.

**Preconditions**
- An audio file has been captured or selected (Sections 10.6.1/10.6.2).

**Postconditions**
- Only technically valid audio proceeds to detection and prediction; invalid audio is rejected with clear feedback.

**User Actions**
- No direct user action; validation occurs automatically upon submission.

**System Behaviour**
- The system SHALL verify the audio file format against the supported format list.
- The system SHALL verify audio duration falls within the defined minimum/maximum bounds.
- The system SHALL detect and reject audio that is silent or near-silent (insufficient signal for analysis).
- The system SHALL pass validated audio to Baby Cry Detection (Section 10.6.4).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYVAL-01 | Audio format must be one of the supported formats (e.g., WAV, MP3, AAC/M4A). |
| VR-CRYVAL-02 | Audio duration must be within the defined minimum/maximum bounds. |
| VR-CRYVAL-03 | Audio signal must exceed a minimum amplitude/energy threshold (not silent). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Audio fails format check | Display "Unsupported audio format" and prevent further processing. |
| Audio is silent/near-silent | Display "No sound detected in this recording. Please try again." |
| Audio duration out of bounds | Display appropriate too-short/too-long message. |

**Success Conditions**
- Only audio meeting all technical validity checks proceeds to the detection pipeline.

---

### 10.6.4 Baby Cry Detection

**Purpose**
To determine whether validated audio actually contains a baby's cry before attempting cry-category classification.

**Description**
Baby Cry Detection is a gating classification step that determines whether the dominant audio content is a baby cry. Only audio positively identified as a baby cry proceeds to full cry-category AI Prediction (Section 10.6.8); all other audio is routed to Non-Baby Sound Detection handling (Section 10.6.5).

**Inputs**
- Validated audio file (from Section 10.6.3).

**Outputs**
- Binary determination: "Baby Cry Detected" or "No Baby Cry Detected," with an associated confidence value.

**Preconditions**
- Audio has passed Audio Validation (Section 10.6.3).

**Postconditions**
- Audio is routed either to cry-category AI Prediction or to Non-Baby Sound Detection handling.

**User Actions**
- No direct user action; detection occurs automatically.

**System Behaviour**
- The system SHALL run a baby-cry-presence detection model on the validated audio prior to cry-category classification.
- The system SHALL route audio identified as containing a baby cry to Feature Extraction (Section 10.6.7) and AI Prediction (Section 10.6.8).
- The system SHALL route audio not identified as a baby cry to Non-Baby Sound Detection (Section 10.6.5).
- The system SHALL NOT classify non-cry audio into any cry category (e.g., Hungry, Tired) under any circumstance.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYDET-01 | Cry-category classification (Section 10.6.8) must only be invoked when Baby Cry Detection returns a positive determination above the defined confidence threshold. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Detection confidence is borderline/ambiguous | Default to the non-baby-cry path and display a neutral "unable to confirm a baby cry" message rather than forcing a cry-category classification. |
| Detection model failure | Display generic analysis-failure error and allow retry. |

**Success Conditions**
- Audio is correctly and consistently routed to the appropriate downstream pipeline based on the presence or absence of a baby cry.

---

### 10.6.5 Non-Baby Sound Detection

**Purpose**
To identify and clearly communicate when submitted audio does not contain a baby's cry, and to classify the general nature of the non-cry sound where feasible.

**Description**
When Baby Cry Detection (Section 10.6.4) determines that audio does not contain a baby cry, Non-Baby Sound Detection attempts to identify the general category of sound present (e.g., Human Speech, Music, Television, Dog Bark, Cat, Vehicle, Rain, Wind, General Noise) for informational display purposes, without ever mapping the result to a cry category.

**Inputs**
- Audio flagged as "No Baby Cry Detected" by Section 10.6.4.

**Outputs**
- A non-cry sound category label (where identifiable) and the message: "This recording does not appear to contain a baby's cry."

**Preconditions**
- Baby Cry Detection (Section 10.6.4) has returned a negative determination.

**Postconditions**
- User is clearly informed that no baby cry was detected; no cry-category prediction is stored or displayed.

**User Actions**
- User reviews the non-cry result and may choose to re-record/re-upload.

**System Behaviour**
- The system SHALL classify the non-cry audio into a general sound category (Human Speech, Music, Television, Dog Bark, Cat, Vehicle, Rain, Wind, Noise) where model confidence permits; otherwise it SHALL label the result generically as "Unrecognized Sound."
- The system SHALL display the message "This recording does not appear to contain a baby's cry" prominently.
- The system SHALL NOT generate or store a cry-category prediction (Hungry, Tired, Discomfort, Gas, Belly Pain) for this audio.
- The system SHALL still record the event in Prediction History (Section 10.6.12) as a "Non-Cry" entry for user reference, distinctly styled from cry-category entries.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-NBSD-01 | A non-cry result must never be accompanied by a cry-category probability distribution. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Non-cry sound category cannot be confidently identified | Display generic "Unrecognized Sound — not a baby cry" without a specific sub-category. |

**Success Conditions**
- Non-cry audio is consistently and clearly identified as such, with an appropriate general sound label where possible, and is never miscategorized as a cry type.

---

### 10.6.6 Noise Reduction

**Purpose**
To improve the reliability of cry classification by reducing background noise and irrelevant acoustic artifacts in the submitted audio prior to feature extraction.

**Description**
Noise Reduction applies signal-processing techniques to attenuate ambient background noise (e.g., television, fan, household sounds) while preserving the cry signal characteristics necessary for accurate classification.

**Inputs**
- Audio confirmed to contain a baby cry (from Section 10.6.4).

**Outputs**
- A denoised audio signal passed to Feature Extraction (Section 10.6.7).

**Preconditions**
- Baby Cry Detection (Section 10.6.4) has returned a positive determination.

**Postconditions**
- A cleaned audio signal is available, improving downstream classification reliability.

**User Actions**
- No direct user action; processing occurs automatically.

**System Behaviour**
- The system SHALL apply noise reduction processing to all audio confirmed as containing a baby cry before feature extraction.
- The system SHALL preserve cry-relevant frequency and temporal characteristics during noise reduction, avoiding over-suppression that could degrade classification accuracy.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYNR-01 | Noise reduction must not be applied in a way that removes more than a defined proportion of total signal energy, to avoid destroying cry-relevant signal content. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Noise reduction processing failure | Fall back to using the original (non-denoised) validated audio for feature extraction, logging the fallback for diagnostic purposes. |

**Success Conditions**
- Background noise is measurably reduced without degrading the integrity of the cry signal used for classification.

---

### 10.6.7 Feature Extraction

**Purpose**
To convert the processed audio signal into a structured feature representation suitable for input into the AI cry classification model.

**Description**
Feature Extraction computes relevant acoustic features (e.g., spectral, temporal, and energy-based characteristics) from the denoised audio, forming the input representation consumed by the AI Prediction step.

**Inputs**
- Denoised audio signal (from Section 10.6.6).

**Outputs**
- A structured feature vector/representation passed to AI Prediction (Section 10.6.8).

**Preconditions**
- Noise Reduction (Section 10.6.6) has completed successfully (or fallback audio is available).

**Postconditions**
- A valid feature representation is available for model inference.

**User Actions**
- No direct user action; processing occurs automatically.

**System Behaviour**
- The system SHALL extract a consistent, defined set of acoustic features from every processed audio sample.
- The system SHALL ensure feature extraction output conforms to the input schema expected by the AI Prediction model.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYFE-01 | Extracted feature representation must be validated for completeness (no missing/corrupt feature values) before being passed to AI Prediction. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Feature extraction failure (e.g., corrupted audio segment) | Abort the analysis pipeline and display a generic "Unable to analyze this recording. Please try again." message. |

**Success Conditions**
- A complete, valid feature representation is produced for every successfully processed cry audio sample.

---

### 10.6.8 AI Prediction

**Purpose**
To classify a validated, processed baby cry recording into probability-weighted cry categories using the AI model.

**Description**
AI Prediction is the core inference step in which the extracted feature representation is passed to the trained classification model, producing a probability distribution across defined cry categories (Hungry, Tired/Sleepy, Discomfort, Gas, Belly Pain).

**Inputs**
- Feature representation (from Section 10.6.7).

**Outputs**
- A probability distribution across cry categories (Section 10.6.10), a primary (highest-probability) prediction, a confidence score (Section 10.6.9), and generated recommendations (Section 10.6.11).

**Preconditions**
- Feature Extraction (Section 10.6.7) has completed successfully.

**Postconditions**
- A complete prediction result is generated and persisted to Prediction History (Section 10.6.12).

**User Actions**
- User views the resulting prediction upon completion of analysis.

**System Behaviour**
- The system SHALL invoke the AI classification model with the extracted feature representation.
- The system SHALL generate a probability value for each defined cry category.
- The system SHALL identify the highest-probability category as the Primary Prediction.
- The system SHALL record the prediction timestamp and source audio duration alongside the result.
- The system SHALL persist the complete prediction result (all category probabilities, primary prediction, confidence score, timestamp, audio duration) to Prediction History.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYPRED-01 | Probability values across all cry categories must be valid (each between 0–100%, not required to sum to exactly 100% given multi-label probability presentation as shown in Section 10.6.10). |
| VR-CRYPRED-02 | A Primary Prediction must always be designated as the highest-probability category among the results. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Model inference failure/timeout | Display "Analysis failed. Please try again." and allow retry without losing the original recording. |
| Model returns low confidence across all categories | Display the result with an explicit low-confidence indicator and a recommendation to observe the baby directly and consult a caregiver/pediatrician if concern persists. |

**Success Conditions**
- A complete, valid prediction result (probability distribution, primary prediction, confidence score, recommendations) is generated and stored for every successfully analyzed baby cry recording.

---

### 10.6.9 Confidence Score

**Purpose**
To communicate, in a clear and interpretable form, how confident the AI model is in its Primary Prediction.

**Description**
The Confidence Score is the probability value associated specifically with the Primary Prediction category, displayed prominently to help the user gauge how strongly to weight the AI's suggestion.

**Inputs**
- Primary Prediction and its associated probability value (from Section 10.6.8).

**Outputs**
- A displayed confidence percentage (e.g., "Hungry — 90% confidence").

**Preconditions**
- AI Prediction (Section 10.6.8) has completed successfully.

**Postconditions**
- User is presented with a clearly interpretable confidence indicator alongside the Primary Prediction.

**User Actions**
- User views the Confidence Score as part of the prediction result screen.

**System Behaviour**
- The system SHALL display the Confidence Score as a percentage value immediately adjacent to the Primary Prediction label.
- The system SHALL apply a visual severity/emphasis treatment (e.g., color coding) reflecting confidence bands (e.g., high/medium/low), consistent with accessibility color-indicator requirements addressed later in this document.
- The system SHALL never present the Confidence Score in a manner implying medical certainty or diagnosis.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYCONF-01 | Confidence Score displayed must exactly match the probability value of the designated Primary Prediction category. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Confidence Score falls below a defined low-confidence threshold | Display an explicit "Low Confidence" label alongside the score and a recommendation to observe the baby directly. |

**Success Conditions**
- The Confidence Score is accurately and clearly displayed for every prediction, correctly reflecting model output.

---

### 10.6.10 Probability Distribution

**Purpose**
To provide full transparency into the AI model's assessment across all cry categories, not solely the top prediction.

**Description**
The Probability Distribution presents the model's computed probability for every defined cry category as a set of visual probability bars (e.g., Hungry 90%, Sleepy 52%, Discomfort 31%, Gas 17%, Belly Pain 12%), allowing the user to see secondary possibilities alongside the Primary Prediction.

**Inputs**
- Full set of per-category probability values (from Section 10.6.8).

**Outputs**
- Rendered probability bars/visualization for each cry category.

**Preconditions**
- AI Prediction (Section 10.6.8) has completed successfully.

**Postconditions**
- User has full visibility into all category probabilities, not just the primary result.

**User Actions**
- User views the probability bars on the prediction result screen.

**System Behaviour**
- The system SHALL display a probability bar (or equivalent visual indicator) for every defined cry category, ordered from highest to lowest probability.
- The system SHALL label each bar with both the category name and its numeric percentage value.
- The system SHALL visually distinguish the Primary Prediction category from secondary categories (e.g., highlighted bar).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYPROB-01 | Every defined cry category must be represented in the Probability Distribution display, even at 0%. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Rendering failure for probability visualization | Fall back to a plain numeric list of category/percentage pairs. |

**Success Conditions**
- All cry category probabilities are accurately and legibly displayed for every prediction.

---

### 10.6.11 Recommendations

**Purpose**
To provide the user with actionable, non-diagnostic guidance based on the Primary Prediction result.

**Description**
Recommendations present suggested caregiver actions associated with the Primary Prediction category (e.g., for "Hungry," suggesting a feeding attempt), framed strictly as informational suggestions rather than medical advice.

**Inputs**
- Primary Prediction category (from Section 10.6.8).

**Outputs**
- One or more suggested action items displayed alongside the prediction result.

**Preconditions**
- AI Prediction (Section 10.6.8) has completed successfully with a valid Primary Prediction.

**Postconditions**
- User receives clear, actionable, non-diagnostic guidance relevant to the predicted cry category.

**User Actions**
- User reads displayed recommendations and may act on them (e.g., navigate to Feeding Tracker to log a resulting feed).

**System Behaviour**
- The system SHALL generate recommendation content mapped to the Primary Prediction category from a maintained, reviewable content set (not model-generated free text, to ensure consistency and safety).
- The system SHALL include a general disclaimer recommending consultation with a pediatrician if the behavior persists or if the caregiver is concerned, consistent with AI Assistant safety requirements (Section 10.14, addressed in a later part of this document).
- The system SHALL avoid any language implying medical diagnosis or certainty.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYREC2-01 | Every Primary Prediction category must have at least one associated, pre-reviewed recommendation available for display. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No recommendation content mapped for a category (e.g., "Non-Cry" or low-confidence result) | Display a generic guidance message (e.g., "Try checking feeding, sleep, and diaper needs, and comfort your baby.") |

**Success Conditions**
- Relevant, safe, non-diagnostic recommendations are displayed for every valid cry prediction.

---

### 10.6.12 Prediction History

**Purpose**
To maintain a persistent, chronological record of all past cry analysis results for a given baby profile.

**Description**
Prediction History stores every completed cry analysis (both cry-category predictions and non-cry results) with full result detail, enabling users to review trends and past events over time.

**Inputs**
- Completed prediction results (from Sections 10.6.8–10.6.11) and non-cry results (from Section 10.6.5).

**Outputs**
- A chronological, filterable list of past cry analysis entries, each expandable to show full result detail (probability distribution, confidence score, recommendations, audio playback).

**Preconditions**
- At least one cry analysis has been completed for the active baby profile.

**Postconditions**
- All completed analyses remain accessible for review until explicitly deleted (Section 10.6.14).

**User Actions**
1. User navigates to Cry History within the Cry Analyzer module.
2. User views the chronological list of past analyses.
3. User taps an entry to view full detail or play back the original audio (Section 10.6.13).

**System Behaviour**
- The system SHALL persist every completed analysis (cry-category and non-cry) to Prediction History, scoped to the active baby profile.
- The system SHALL display entries in reverse-chronological order by default.
- The system SHALL retain the original audio reference (or file) associated with each entry to support playback.
- The system SHALL synchronize Prediction History to the cloud when connectivity is available, consistent with Offline Mode and Cloud Synchronization requirements (addressed in a later part of this document).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYHIST-01 | Prediction History entries must only be visible for the baby profile they are associated with (per Data Separation, Section 10.4.4). |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- All completed cry analyses are reliably recorded, retained, and reviewable in chronological order.

---

### 10.6.13 Audio Playback

**Purpose**
To allow users to replay the original audio associated with a past cry analysis entry.

**Description**
Audio Playback provides in-app playback controls (play, pause, seek) for the audio recording tied to any Prediction History entry, allowing users to re-listen to a captured cry alongside its analysis result.

**Inputs**
- User playback control actions (play/pause/seek) on a selected Prediction History entry.

**Outputs**
- Audible playback of the stored recording, with visual playback progress indication.

**Preconditions**
- A Prediction History entry with an associated stored audio file exists (Section 10.6.12).

**Postconditions**
- User has reviewed the original audio corresponding to a past analysis.

**User Actions**
1. User selects a Prediction History entry.
2. User taps "Play" to begin playback.
3. User may pause, seek, or replay as desired.

**System Behaviour**
- The system SHALL provide standard playback controls (play, pause, seek, elapsed/total time) for any entry with available audio.
- The system SHALL display a visual waveform or progress indicator during playback to support accessibility for users who may not rely on audio alone to gauge playback state.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYPLAY-01 | Playback must only be available for entries with a valid, retained audio file reference. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Audio file unavailable/corrupted | Display "Audio unavailable for this entry" and disable playback controls for that entry. |

**Success Conditions**
- Users can reliably play back stored audio for any valid Prediction History entry.

---

### 10.6.14 Delete History

**Purpose**
To allow users to remove Prediction History entries (and their associated audio) that are no longer needed.

**Description**
Delete History allows a user to permanently remove one or more Prediction History entries, including the associated stored audio file, from both local and cloud storage.

**Inputs**
- User selection of one or more Prediction History entries for deletion, and confirmation action.

**Outputs**
- Removal of the selected entry/entries and associated audio from local and cloud storage.

**Preconditions**
- At least one Prediction History entry exists.
- User holds sufficient role permission to delete records for the active baby profile (see Role-Based Access, addressed in a later part of this document).

**Postconditions**
- Deleted entries are no longer visible in Prediction History and their audio files are removed from storage.

**User Actions**
1. User selects one or more entries in Prediction History (e.g., via swipe-to-delete or multi-select).
2. User confirms the deletion action in a confirmation prompt.

**System Behaviour**
- The system SHALL require explicit user confirmation before permanently deleting any Prediction History entry, given the irreversible nature of the action.
- The system SHALL remove the entry and its associated audio file from local storage immediately.
- The system SHALL queue the corresponding deletion for cloud synchronization if performed while offline, applying it once connectivity is restored.
- The system SHALL log the deletion action for audit purposes where required by Security Requirements (addressed in a later part of this document).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRYDEL-01 | Deletion must require explicit confirmation and must not be triggerable by a single accidental tap. |
| VR-CRYDEL-02 | Only users with appropriate role permission may delete Prediction History entries. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Deletion fails (e.g., storage error) | Display error message and retain the entry, allowing retry. |
| Deletion attempted without sufficient permission | Deny the action and display an appropriate permission-denied message. |

**Success Conditions**
- Selected entries and their associated audio are reliably and permanently removed upon confirmed deletion, both locally and (once synchronized) in the cloud.

---

## 10.7 Feeding Tracker

### 10.7.1 Breastfeeding

**Purpose**
To allow users to log breastfeeding sessions, capturing timing and breast-side detail.

**Description**
Breastfeeding logging captures a feeding session's start time, end time, duration, and which breast(s) were used, forming the basis for breastfeeding-specific statistics and side-alternation suggestions.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Start Time | Timestamp | Yes |
| End Time | Timestamp | Yes (or derived from Feeding Timer, Section 10.7.5) |
| Breast Side Used | Selection (Left / Right / Both) | Yes |
| Notes | Text | No |

**Outputs**
- A persisted breastfeeding session record associated with the active baby profile.
- Updated Feeding History (Section 10.7.9) and statistics (Sections 10.7.10–10.7.12).

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The breastfeeding session is recorded and reflected in Dashboard, History, and Statistics views.

**User Actions**
1. User navigates to Feeding Tracker and selects "Breastfeeding."
2. User starts the session (manually or via Feeding Timer) and selects breast side.
3. User ends the session and optionally adds notes.
4. User saves the entry.

**System Behaviour**
- The system SHALL calculate session Duration automatically as End Time minus Start Time.
- The system SHALL record the Breast Side Used and update Last Breast Used state for the active baby (see Section 10.7.6–10.7.8).
- The system SHALL persist the completed session to Feeding History.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BF-01 | End Time must be after Start Time. |
| VR-BF-02 | Breast Side Used must be selected from Left / Right / Both. |
| VR-BF-03 | Session duration must fall within a plausible range (flagging unusually long sessions for confirmation). |

**Error Handling**

| Scenario | System Response |
|---|---|
| End Time before Start Time | Display validation error and prevent save. |
| Breast side not selected | Prevent save; display inline validation prompt. |

**Success Conditions**
- A valid breastfeeding session is saved and correctly reflected across History and Statistics.

---

### 10.7.2 Bottle Feeding

**Purpose**
To allow users to log bottle feeding sessions, capturing milk type, volume, and timing detail.

**Description**
Bottle Feeding logging captures the type of milk, bottle size, amount consumed, temperature, and session timing, supporting intake statistics (Sections 10.7.10–10.7.12).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Milk Type | Selection (Breast Milk / Formula / Mixed) | Yes |
| Bottle Size | Numeric (ml/oz) | No |
| Amount (ml) | Numeric | Yes |
| Temperature | Selection (Cold / Room Temp / Warm) | No |
| Start Time | Timestamp | Yes |
| End Time | Timestamp | No |

**Outputs**
- A persisted bottle feeding session record.
- Updated Feeding History and Daily/Weekly/Monthly Intake statistics.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The bottle feeding session is recorded and reflected in Dashboard, History, and Statistics views.

**User Actions**
1. User navigates to Feeding Tracker and selects "Bottle Feeding."
2. User enters milk type, amount, and optionally bottle size/temperature.
3. User records start (and optionally end) time.
4. User saves the entry.

**System Behaviour**
- The system SHALL record Amount (ml) as the primary value used in intake aggregation.
- The system SHALL support unit conversion between ml and oz for display, per user Settings preference (addressed in a later part of this document).
- The system SHALL persist the completed session to Feeding History and update intake statistics.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BOT-01 | Amount must be a positive numeric value within a plausible range. |
| VR-BOT-02 | Milk Type must be selected. |
| VR-BOT-03 | Start Time must not be a future timestamp. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Amount is zero, negative, or non-numeric | Display inline validation error and prevent save. |
| Milk Type not selected | Prevent save; display inline validation prompt. |

**Success Conditions**
- A valid bottle feeding session is saved and correctly reflected in intake statistics.

---

### 10.7.3 Formula Feeding

**Purpose**
To allow users to log formula-specific feeding sessions distinctly from breast milk bottle feeding, where formula preparation detail is relevant.

**Description**
Formula Feeding extends Bottle Feeding logging (Section 10.7.2) with formula-specific attributes (e.g., formula brand/type), while sharing the same amount, timing, and statistics infrastructure.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Formula Brand/Type | Text/Selection | No |
| Amount (ml) | Numeric | Yes |
| Start Time | Timestamp | Yes |
| End Time | Timestamp | No |
| Notes | Text | No |

**Outputs**
- A persisted formula feeding session record, tagged as Milk Type = Formula within the unified Feeding History.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The formula feeding session is recorded and included in Bottle/Formula intake statistics.

**User Actions**
1. User navigates to Feeding Tracker and selects "Formula Feeding" (or selects Milk Type = Formula within Bottle Feeding).
2. User enters amount and optional formula brand/type.
3. User saves the entry.

**System Behaviour**
- The system SHALL treat Formula Feeding entries as a Milk-Type-tagged variant of Bottle Feeding for the purposes of unified intake statistics, while retaining formula-specific fields distinctly in the record.
- The system SHALL persist the completed session to Feeding History.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FOR-01 | Amount must be a positive numeric value within a plausible range (consistent with VR-BOT-01). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Amount invalid | Display inline validation error and prevent save. |

**Success Conditions**
- A valid formula feeding session is saved and correctly reflected in Feeding History and intake statistics.

---

### 10.7.4 Solid Feeding

**Purpose**
To allow users to log solid food feeding sessions once the baby has progressed to complementary feeding.

**Description**
Solid Feeding logging captures food type(s), quantity/portion (where meaningful), and the baby's reaction, supporting later dietary review and allergy awareness.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Food Item(s) | Text/Multi-entry | Yes |
| Quantity/Portion | Text or Numeric | No |
| Reaction | Selection (Liked / Neutral / Disliked / Allergic Reaction) | No |
| Start Time | Timestamp | Yes |
| Notes | Text | No |

**Outputs**
- A persisted solid feeding session record.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The solid feeding session is recorded and reflected in Feeding History.

**User Actions**
1. User navigates to Feeding Tracker and selects "Solid Feeding."
2. User enters food item(s), optional quantity, and reaction.
3. User saves the entry.

**System Behaviour**
- The system SHALL persist the completed session to Feeding History.
- If Reaction is set to "Allergic Reaction," the system SHOULD prompt the user to consider recording the item under Medical Information / Known Allergies (Section 10.3.3).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SOL-01 | Food Item(s) field must not be empty. |
| VR-SOL-02 | Start Time must not be a future timestamp. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Food Item(s) empty | Display inline validation error and prevent save. |

**Success Conditions**
- A valid solid feeding session is saved and correctly reflected in Feeding History.

---

### 10.7.5 Feeding Timer

**Purpose**
To allow users to time a feeding session (breastfeeding or bottle) in real time rather than manually entering start/end times after the fact.

**Description**
The Feeding Timer provides a start/pause/stop timer interface usable during an active feeding session, automatically populating Start Time, End Time, and Duration upon completion.

**Inputs**
- User start/pause/resume/stop actions.

**Outputs**
- Automatically calculated Start Time, End Time, and Duration values populated into the corresponding feeding entry (breastfeeding or bottle).

**Preconditions**
- User has initiated a Breastfeeding or Bottle Feeding entry in "live timing" mode.

**Postconditions**
- Timer-derived timing values are saved as part of the completed feeding session record.

**User Actions**
1. User taps "Start Timer" at the beginning of a feeding session.
2. User may pause/resume the timer (e.g., for breast switching).
3. User taps "Stop" to end the session.
4. User confirms and saves the entry.

**System Behaviour**
- The system SHALL record the wall-clock Start Time upon timer start and End Time upon timer stop.
- The system SHALL support pause/resume, excluding paused duration from the active Duration calculation, or SHOULD clearly indicate if paused time is included, based on configured behavior for the feature (breastfeeding side-switch pauses SHOULD be excluded from total active feeding duration).
- The system SHALL continue running the timer accurately even if the app is backgrounded, resuming display correctly upon return.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FT-01 | Timer must not allow a Stop action before a Start action has occurred. |

**Error Handling**

| Scenario | System Response |
|---|---|
| App is closed/killed mid-timer | Persist timer state locally and restore accurately upon app reopen, or prompt the user to confirm/adjust the session duration if restoration is not possible. |

**Success Conditions**
- Timer-derived Start Time, End Time, and Duration are accurately captured and applied to the resulting feeding record.

---

### 10.7.6 Left Breast

**Purpose**
To specifically record and track breastfeeding sessions using the left breast.

**Description**
Left Breast is a selectable value within Breastfeeding logging (Section 10.7.1), used both to tag individual sessions and to compute Last Breast Used and side-alternation suggestions.

**Inputs**
- User selection of "Left" as Breast Side Used during a breastfeeding entry.

**Outputs**
- Session tagged as Left Breast; contributes to Left-side usage statistics and Last Breast Used state.

**Preconditions**
- User is logging a breastfeeding session (Section 10.7.1).

**Postconditions**
- Left Breast usage is reflected in statistics and side-alternation logic.

**User Actions**
- User selects "Left" when logging a breastfeeding session.

**System Behaviour**
- The system SHALL update the Last Breast Used indicator to "Left" upon saving a session tagged Left.
- The system SHALL include Left Breast sessions in per-side usage statistics.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-LB-01 | A session may be tagged Left only if not simultaneously tagged Right or Both for the same entry (mutually exclusive selection, see VR-BF-02). |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A (covered under Breastfeeding validation, Section 10.7.1) | N/A |

**Success Conditions**
- Left Breast sessions are accurately tagged and reflected in Last Breast Used state and statistics.

---

### 10.7.7 Right Breast

**Purpose**
To specifically record and track breastfeeding sessions using the right breast.

**Description**
Right Breast is a selectable value within Breastfeeding logging (Section 10.7.1), functioning symmetrically to Left Breast (Section 10.7.6) for tracking and alternation-suggestion purposes.

**Inputs**
- User selection of "Right" as Breast Side Used during a breastfeeding entry.

**Outputs**
- Session tagged as Right Breast; contributes to Right-side usage statistics and Last Breast Used state.

**Preconditions**
- User is logging a breastfeeding session (Section 10.7.1).

**Postconditions**
- Right Breast usage is reflected in statistics and side-alternation logic.

**User Actions**
- User selects "Right" when logging a breastfeeding session.

**System Behaviour**
- The system SHALL update the Last Breast Used indicator to "Right" upon saving a session tagged Right.
- The system SHALL include Right Breast sessions in per-side usage statistics.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-RB-01 | A session may be tagged Right only if not simultaneously tagged Left or Both for the same entry. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A (covered under Breastfeeding validation, Section 10.7.1) | N/A |

**Success Conditions**
- Right Breast sessions are accurately tagged and reflected in Last Breast Used state and statistics.

---

### 10.7.8 Both Breasts

**Purpose**
To record breastfeeding sessions in which both breasts were used within a single session.

**Description**
Both Breasts is a selectable value within Breastfeeding logging (Section 10.7.1) for sessions spanning both sides, typically used together with Feeding Timer pause/resume (Section 10.7.5) to demarcate the side switch.

**Inputs**
- User selection of "Both" as Breast Side Used during a breastfeeding entry.

**Outputs**
- Session tagged as Both Breasts; contributes to combined-side usage statistics.

**Preconditions**
- User is logging a breastfeeding session (Section 10.7.1).

**Postconditions**
- Both Breasts usage is reflected in statistics; Last Breast Used is set based on the side used last within the session, if captured, or defaults to "Both" if not distinguished.

**User Actions**
- User selects "Both" when logging a breastfeeding session, optionally recording sub-timings per side via the Feeding Timer.

**System Behaviour**
- The system SHALL support tagging a session as Both Breasts.
- The system SHOULD, where the Feeding Timer captures per-side sub-durations, record and display the individual Left/Right duration split within a Both-tagged session.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BB-01 | A session tagged Both must not simultaneously be tagged solely Left or solely Right (mutually exclusive top-level selection). |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A (covered under Breastfeeding validation, Section 10.7.1) | N/A |

**Success Conditions**
- Both Breasts sessions are accurately tagged and reflected in statistics, with per-side sub-durations captured where available.

---

### 10.7.9 Feeding History

**Purpose**
To provide a complete, chronological record of all feeding sessions (breastfeeding, bottle, formula, solid) for the active baby.

**Description**
Feeding History consolidates all feeding session types into a unified, filterable, chronological timeline, allowing users to review past feeding activity in detail.

**Inputs**
- All persisted feeding session records (Sections 10.7.1–10.7.4) for the active baby.

**Outputs**
- A chronological, filterable list of feeding sessions, each showing type, timing, amount/duration, and notes.

**Preconditions**
- At least one feeding session has been logged.

**Postconditions**
- All logged feeding sessions remain accessible for review, editing, and deletion.

**User Actions**
1. User navigates to Feeding History.
2. User filters/sorts by feeding type or date range.
3. User taps an entry to view, edit, or delete it.

**System Behaviour**
- The system SHALL display feeding sessions in reverse-chronological order by default.
- The system SHALL allow filtering by feeding type (Breastfeeding, Bottle, Formula, Solid) and by date range.
- The system SHALL allow editing and deletion of existing entries, subject to role permission (addressed in a later part of this document).
- The system SHALL update Daily/Weekly/Monthly Statistics (Sections 10.7.10–10.7.12) immediately upon any create/edit/delete action.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FH-01 | Feeding History must only display entries belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |
| Edit results in invalid data (e.g., End Time before Start Time) | Apply the same validation rules as original entry creation and block the save. |

**Success Conditions**
- All feeding sessions are accurately, completely, and promptly reflected in Feeding History.

---

### 10.7.10 Daily Statistics

**Purpose**
To provide an automatically calculated summary of feeding activity for the current day.

**Description**
Daily Statistics aggregate the current day's feeding sessions into summary figures, including Total Feeds, Average Feed Duration (breastfeeding), and Daily Intake volume (bottle/formula).

**Inputs**
- All feeding session records timestamped within the current calendar day for the active baby.

**Outputs**
- Computed Daily Statistics values (Total Feeds, Average Feed Duration, Daily Intake in ml).

**Preconditions**
- At least one feeding session exists for the current day (otherwise a zero/empty state is shown).

**Postconditions**
- User has an accurate current-day feeding summary.

**User Actions**
- User views Daily Statistics within Feeding Tracker or Dashboard Daily Summary (Section 10.5.2).

**System Behaviour**
- The system SHALL calculate Total Feeds as the count of all feeding sessions (all types) logged for the current day.
- The system SHALL calculate Average Feed Duration from breastfeeding sessions logged on the current day.
- The system SHALL calculate Daily Intake (ml) as the sum of Amount values from bottle/formula sessions logged on the current day.
- The system SHALL recalculate these values immediately upon any relevant create/edit/delete action.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FDS-01 | Daily Statistics must only include sessions belonging to the active baby profile and timestamped within the current calendar day. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No sessions logged today | Display zero-value state (e.g., "0 Feeds Today"). |

**Success Conditions**
- Daily Statistics accurately reflect all feeding activity logged for the current day at all times.

---

### 10.7.11 Weekly Statistics

**Purpose**
To provide an automatically calculated summary of feeding activity over the trailing seven-day period.

**Description**
Weekly Statistics aggregate feeding sessions from the past seven days, presenting trend-oriented figures such as Total Weekly Feeds, Average Daily Intake, and day-by-day breakdown.

**Inputs**
- All feeding session records timestamped within the trailing seven-day window for the active baby.

**Outputs**
- Computed Weekly Statistics values and, where applicable, a day-by-day trend visualization.

**Preconditions**
- At least one feeding session exists within the trailing seven-day window.

**Postconditions**
- User has an accurate weekly feeding trend summary.

**User Actions**
- User views Weekly Statistics within Feeding Tracker or Reports (addressed in a later part of this document).

**System Behaviour**
- The system SHALL calculate Weekly Statistics using a rolling seven-day window ending on the current date, unless the user selects a specific past week.
- The system SHALL present both aggregate totals (e.g., Total Weekly Intake) and daily breakdowns within the week.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FWS-01 | Weekly Statistics must only include sessions belonging to the active baby profile and within the selected seven-day window. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for the selected week | Display "Not enough data yet" or zero-value state as appropriate. |

**Success Conditions**
- Weekly Statistics accurately reflect feeding activity across the selected seven-day window.

---

### 10.7.12 Monthly Statistics

**Purpose**
To provide an automatically calculated summary of feeding activity over a calendar month, supporting longer-term trend awareness.

**Description**
Monthly Statistics aggregate feeding sessions across a full calendar month, presenting totals and trend visualizations useful for identifying longer-term feeding pattern changes, including relevance to pediatric review.

**Inputs**
- All feeding session records timestamped within the selected calendar month for the active baby.

**Outputs**
- Computed Monthly Statistics values and trend visualization (e.g., weekly sub-totals within the month).

**Preconditions**
- At least one feeding session exists within the selected month.

**Postconditions**
- User has an accurate monthly feeding trend summary suitable for longer-term review.

**User Actions**
- User views Monthly Statistics within Feeding Tracker or Reports (addressed in a later part of this document), optionally selecting a specific past month.

**System Behaviour**
- The system SHALL calculate Monthly Statistics for the currently selected calendar month, defaulting to the current month.
- The system SHALL support navigation to previous months for historical review, subject to data retention (see Assumptions/Dependencies, addressed in a later part of this document).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FMS-01 | Monthly Statistics must only include sessions belonging to the active baby profile and within the selected calendar month. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for the selected month | Display "Not enough data yet" or zero-value state as appropriate. |

**Success Conditions**
- Monthly Statistics accurately reflect feeding activity across the selected calendar month.

---

## 10.8 Sleep Tracker

### 10.8.1 Sleep Start

**Purpose**
To allow users to record the beginning of a baby's sleep session.

**Description**
Sleep Start captures the timestamp at which a sleep session begins, either logged in real time (tap "Start Sleep") or entered retroactively.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Start Time | Timestamp | Yes |

**Outputs**
- A new in-progress sleep session record with a recorded Start Time.

**Preconditions**
- An active baby profile is selected.
- No other sleep session is currently in progress for the active baby (see Error Handling).

**Postconditions**
- An in-progress sleep session exists, pending Sleep End (Section 10.8.2).

**User Actions**
1. User navigates to Sleep Tracker.
2. User taps "Start Sleep" (or manually enters a retroactive start time).

**System Behaviour**
- The system SHALL record the current timestamp as Start Time upon "Start Sleep" activation, or accept a manually entered retroactive Start Time.
- The system SHALL prevent more than one concurrent in-progress sleep session per baby profile.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SS-01 | Start Time, if manually entered, must not be a future timestamp. |
| VR-SS-02 | Only one in-progress sleep session may exist per baby profile at a time. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Attempt to start a new session while one is already in progress | Display "A sleep session is already in progress" and offer to end the existing session first. |

**Success Conditions**
- A valid in-progress sleep session is created with an accurate Start Time.

---

### 10.8.2 Sleep End

**Purpose**
To allow users to record the end of a baby's sleep session and finalize its duration.

**Description**
Sleep End captures the timestamp at which an in-progress sleep session concludes, triggering automatic Duration calculation (Section 10.8.3) and classification into Day Sleep or Night Sleep (Sections 10.8.4–10.8.5).

**Inputs**

| Field | Type | Required |
|---|---|---|
| End Time | Timestamp | Yes |
| Sleep Quality | Selection (e.g., Good / Fussy / Restless) | No |

**Outputs**
- A completed sleep session record with Start Time, End Time, Duration, Day/Night classification, and optional Quality.

**Preconditions**
- An in-progress sleep session exists (Section 10.8.1).

**Postconditions**
- The sleep session is finalized and reflected in Sleep History and Statistics.

**User Actions**
1. User taps "End Sleep" on the in-progress session.
2. User optionally selects Sleep Quality.
3. User saves the completed entry.

**System Behaviour**
- The system SHALL record End Time upon "End Sleep" activation, or accept a manually corrected End Time.
- The system SHALL automatically calculate Duration as End Time minus Start Time.
- The system SHALL automatically classify the session as Day Sleep or Night Sleep based on configured time-of-day boundaries (see Section 10.8.4–10.8.5), while allowing manual override.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SE-01 | End Time must be after Start Time. |
| VR-SE-02 | End Time must not be a future timestamp. |

**Error Handling**

| Scenario | System Response |
|---|---|
| End Time before Start Time | Display validation error and prevent save. |
| No in-progress session exists when "End Sleep" is invoked | Display error and prompt user to start a session or manually enter a full past session. |

**Success Conditions**
- A valid, complete sleep session is saved with accurate Duration and Day/Night classification.

---

### 10.8.3 Duration

**Purpose**
To provide an accurate, automatically derived measure of how long a sleep session lasted.

**Description**
Duration is a calculated field, derived from Start Time and End Time, used throughout Sleep History and Statistics (Sections 10.8.6–10.8.9).

**Inputs**
- Start Time (Section 10.8.1) and End Time (Section 10.8.2) of a sleep session.

**Outputs**
- A computed Duration value (hours and minutes) stored with the sleep session record.

**Preconditions**
- Both Start Time and End Time are recorded for a session.

**Postconditions**
- Duration is available for display and statistical aggregation.

**User Actions**
- No direct user action; Duration is calculated automatically. User may view the computed Duration on the session entry.

**System Behaviour**
- The system SHALL calculate Duration as End Time minus Start Time at the moment a session is finalized.
- The system SHALL recalculate Duration automatically if Start Time or End Time is later edited.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DUR-01 | Duration must always be a positive value (enforced via VR-SE-01). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Edited times would result in a negative or zero duration | Reject the edit and display validation error. |

**Success Conditions**
- Duration is accurately and consistently calculated for every completed sleep session.

---

### 10.8.4 Day Sleep

**Purpose**
To distinguish and separately track sleep sessions occurring during defined daytime hours.

**Description**
Day Sleep is a classification applied to sleep sessions falling primarily within a configurable daytime window (e.g., naps), used to compute separate day-sleep statistics distinct from overnight sleep.

**Inputs**
- Session Start/End Time relative to the configured day/night boundary (Settings, addressed in a later part of this document).

**Outputs**
- Session tagged as Day Sleep, included in day-sleep-specific statistics.

**Preconditions**
- A completed sleep session exists (Section 10.8.2).

**Postconditions**
- Day Sleep classification is reflected in Sleep History and Statistics.

**User Actions**
- User may manually override the automatic Day/Night classification if desired.

**System Behaviour**
- The system SHALL automatically classify a session as Day Sleep if its Start Time falls within the configured daytime window (default, e.g., 06:00–18:00, user-configurable).
- The system SHALL allow manual override of the automatic classification.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DS2-01 | A session must be classified as either Day Sleep or Night Sleep, never both simultaneously (sessions spanning the boundary are classified by Start Time, per system default). |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- Day Sleep sessions are accurately and consistently classified and reflected in statistics.

---

### 10.8.5 Night Sleep

**Purpose**
To distinguish and separately track sleep sessions occurring during defined nighttime hours.

**Description**
Night Sleep is the complementary classification to Day Sleep (Section 10.8.4), applied to sessions falling within the configured nighttime window, used to compute night-sleep-specific statistics (a key indicator for parents and pediatricians).

**Inputs**
- Session Start/End Time relative to the configured day/night boundary.

**Outputs**
- Session tagged as Night Sleep, included in night-sleep-specific statistics.

**Preconditions**
- A completed sleep session exists (Section 10.8.2).

**Postconditions**
- Night Sleep classification is reflected in Sleep History and Statistics.

**User Actions**
- User may manually override the automatic Day/Night classification if desired.

**System Behaviour**
- The system SHALL automatically classify a session as Night Sleep if its Start Time falls within the configured nighttime window (default, e.g., 18:00–06:00, user-configurable).
- The system SHALL allow manual override of the automatic classification.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-NS-01 | A session must be classified as either Day Sleep or Night Sleep, never both simultaneously (consistent with VR-DS2-01). |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- Night Sleep sessions are accurately and consistently classified and reflected in statistics.

---

### 10.8.6 Sleep History

**Purpose**
To provide a complete, chronological record of all sleep sessions for the active baby.

**Description**
Sleep History consolidates all completed (and any currently in-progress) sleep sessions into a filterable, chronological timeline.

**Inputs**
- All persisted sleep session records for the active baby.

**Outputs**
- A chronological, filterable list of sleep sessions, each showing Start Time, End Time, Duration, Day/Night classification, and Quality.

**Preconditions**
- At least one sleep session has been logged.

**Postconditions**
- All logged sleep sessions remain accessible for review, editing, and deletion.

**User Actions**
1. User navigates to Sleep History.
2. User filters/sorts by date range or Day/Night classification.
3. User taps an entry to view, edit, or delete it.

**System Behaviour**
- The system SHALL display sleep sessions in reverse-chronological order by default.
- The system SHALL allow editing and deletion of existing entries, subject to role permission.
- The system SHALL update Daily/Weekly/Monthly Sleep Statistics (Sections 10.8.7–10.8.9) immediately upon any create/edit/delete action.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SH-01 | Sleep History must only display entries belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- All sleep sessions are accurately, completely, and promptly reflected in Sleep History.

---

### 10.8.7 Daily Sleep Statistics

**Purpose**
To provide an automatically calculated summary of sleep activity for the current day.

**Description**
Daily Sleep Statistics aggregate the current day's sleep sessions into summary figures, including Total Sleep Duration, Day Sleep total, and Night Sleep total.

**Inputs**
- All sleep session records timestamped within the current calendar day (or overnight session spanning into it) for the active baby.

**Outputs**
- Computed Daily Sleep Statistics values (Total Sleep, Day Sleep total, Night Sleep total, number of sessions).

**Preconditions**
- At least one sleep session exists for the current day.

**Postconditions**
- User has an accurate current-day sleep summary.

**User Actions**
- User views Daily Sleep Statistics within Sleep Tracker or Dashboard Daily Summary.

**System Behaviour**
- The system SHALL calculate Total Sleep Duration as the sum of all session durations attributed to the current day.
- The system SHALL separately total Day Sleep and Night Sleep durations for the current day.
- The system SHALL recalculate these values immediately upon any relevant create/edit/delete action.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SDS-01 | Daily Sleep Statistics must only include sessions belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No sessions logged today | Display zero-value state. |

**Success Conditions**
- Daily Sleep Statistics accurately reflect all sleep activity for the current day at all times.

---

### 10.8.8 Weekly Sleep Statistics

**Purpose**
To provide an automatically calculated summary of sleep activity and trends over the trailing seven-day period.

**Description**
Weekly Sleep Statistics aggregate sleep sessions from the past seven days, presenting Average Daily Sleep, Sleep Trends (e.g., improving/declining night sleep), and a day-by-day breakdown.

**Inputs**
- All sleep session records within the trailing seven-day window for the active baby.

**Outputs**
- Computed Weekly Sleep Statistics values and trend visualization.

**Preconditions**
- At least one sleep session exists within the trailing seven-day window.

**Postconditions**
- User has an accurate weekly sleep trend summary.

**User Actions**
- User views Weekly Sleep Statistics within Sleep Tracker or Reports.

**System Behaviour**
- The system SHALL calculate Weekly Sleep Statistics using a rolling seven-day window ending on the current date by default.
- The system SHALL compute Sleep Trends by comparing the current week's totals against the prior week where sufficient data exists.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SWS-01 | Weekly Sleep Statistics must only include sessions belonging to the active baby profile and within the selected window. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for trend comparison | Display current-week totals without a trend indicator, rather than a misleading trend. |

**Success Conditions**
- Weekly Sleep Statistics and trends accurately reflect sleep activity across the selected seven-day window.

---

### 10.8.9 Monthly Sleep Statistics

**Purpose**
To provide an automatically calculated summary of sleep activity over a calendar month, supporting longer-term developmental trend awareness.

**Description**
Monthly Sleep Statistics aggregate sleep sessions across a full calendar month, presenting totals and trend visualizations relevant to identifying longer-term sleep pattern changes.

**Inputs**
- All sleep session records within the selected calendar month for the active baby.

**Outputs**
- Computed Monthly Sleep Statistics values and trend visualization.

**Preconditions**
- At least one sleep session exists within the selected month.

**Postconditions**
- User has an accurate monthly sleep trend summary.

**User Actions**
- User views Monthly Sleep Statistics within Sleep Tracker or Reports, optionally selecting a specific past month.

**System Behaviour**
- The system SHALL calculate Monthly Sleep Statistics for the currently selected calendar month, defaulting to the current month.
- The system SHALL support navigation to previous months for historical review.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SMS-01 | Monthly Sleep Statistics must only include sessions belonging to the active baby profile and within the selected calendar month. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for the selected month | Display "Not enough data yet" or zero-value state as appropriate. |

**Success Conditions**
- Monthly Sleep Statistics accurately reflect sleep activity across the selected calendar month.

---

## 10.9 Diaper Tracker

### 10.9.1 Pee

**Purpose**
To allow users to log a wet (urine-only) diaper change event.

**Description**
Pee logging records a diaper change identified as containing urine only, contributing to diaper-type statistics and general hydration/output awareness.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Timestamp | Timestamp | Yes |
| Size | Selection (Small / Medium / Large) | No |
| Notes | Text | No |

**Outputs**
- A persisted diaper change record tagged Type = Pee.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The Pee event is recorded and reflected in Timeline and Statistics.

**User Actions**
1. User navigates to Diaper Tracker.
2. User selects "Pee" as the diaper type.
3. User optionally records Size and Notes.
4. User saves the entry.

**System Behaviour**
- The system SHALL record the entry with Type = Pee and the current or user-specified timestamp.
- The system SHALL include Pee entries in Daily/Weekly Statistics (Sections 10.9.9–10.9.10).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PEE-01 | Timestamp must not be a future timestamp. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Timestamp invalid | Display inline validation error and prevent save. |

**Success Conditions**
- A valid Pee entry is saved and reflected in Timeline and Statistics.

---

### 10.9.2 Poop

**Purpose**
To allow users to log a soiled (bowel movement) diaper change event.

**Description**
Poop logging records a diaper change identified as containing a bowel movement, with additional detail (Color, Size, Notes) relevant to health monitoring.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Timestamp | Timestamp | Yes |
| Size | Selection (Small / Medium / Large) | No |
| Color | Selection (see Section 10.9.6) | No |
| Notes | Text | No |

**Outputs**
- A persisted diaper change record tagged Type = Poop.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The Poop event is recorded and reflected in Timeline and Statistics.

**User Actions**
1. User navigates to Diaper Tracker.
2. User selects "Poop" as the diaper type.
3. User optionally records Size, Color, and Notes.
4. User saves the entry.

**System Behaviour**
- The system SHALL record the entry with Type = Poop and the current or user-specified timestamp.
- The system SHALL include Poop entries in Daily/Weekly Statistics.
- The system SHOULD surface a gentle informational note if Color selection indicates a value commonly associated with the need for pediatric consultation (e.g., red or white/pale stool), without presenting this as a diagnosis, consistent with AI Assistant safety principles (Section 10.14, addressed in a later part of this document).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-POOP-01 | Timestamp must not be a future timestamp. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Timestamp invalid | Display inline validation error and prevent save. |

**Success Conditions**
- A valid Poop entry is saved and reflected in Timeline and Statistics.

---

### 10.9.3 Mixed

**Purpose**
To allow users to log a diaper change event containing both urine and bowel movement in a single occurrence.

**Description**
Mixed logging records a combined diaper event, avoiding the need to log two separate entries when both occur together, while still contributing accurately to both Pee-related and Poop-related statistics.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Timestamp | Timestamp | Yes |
| Size | Selection (Small / Medium / Large) | No |
| Color | Selection | No |
| Notes | Text | No |

**Outputs**
- A persisted diaper change record tagged Type = Mixed.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The Mixed event is recorded and reflected in Timeline and Statistics, counted appropriately within both Pee and Poop aggregate figures.

**User Actions**
1. User navigates to Diaper Tracker.
2. User selects "Mixed" as the diaper type.
3. User optionally records Size, Color, and Notes.
4. User saves the entry.

**System Behaviour**
- The system SHALL record the entry with Type = Mixed and the current or user-specified timestamp.
- The system SHALL count Mixed entries within both Pee-count and Poop-count statistics, while also reporting a distinct Mixed-count total, to avoid undercounting either category.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MIX-01 | Timestamp must not be a future timestamp. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Timestamp invalid | Display inline validation error and prevent save. |

**Success Conditions**
- A valid Mixed entry is saved and correctly reflected across combined and category-specific Statistics.

---

### 10.9.4 Dry

**Purpose**
To allow users to log a diaper check that resulted in no wet or soiled content, for completeness of the care record.

**Description**
Dry logging records that a diaper check occurred and the diaper was found dry/clean, useful for maintaining an accurate check-frequency record distinct from actual output events.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Timestamp | Timestamp | Yes |
| Notes | Text | No |

**Outputs**
- A persisted diaper change record tagged Type = Dry.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- The Dry check event is recorded and reflected in Timeline and Statistics.

**User Actions**
1. User navigates to Diaper Tracker.
2. User selects "Dry" as the diaper type.
3. User saves the entry.

**System Behaviour**
- The system SHALL record the entry with Type = Dry and the current or user-specified timestamp.
- The system SHALL exclude Dry entries from Pee/Poop output-volume statistics while still including them in total diaper-check counts.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DRY-01 | Timestamp must not be a future timestamp. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Timestamp invalid | Display inline validation error and prevent save. |

**Success Conditions**
- A valid Dry entry is saved and reflected in Timeline and total check-count Statistics.

---

### 10.9.5 Size

**Purpose**
To capture the relative size/volume of a diaper change event where relevant.

**Description**
Size is a shared attribute available across Pee, Poop, and Mixed diaper entries (Sections 10.9.1–10.9.3), recorded as a simple relative scale to support trend awareness without requiring precise measurement.

**Inputs**
- User selection of Size: Small / Medium / Large.

**Outputs**
- Size value stored as part of the associated diaper entry.

**Preconditions**
- User is logging a Pee, Poop, or Mixed diaper entry.

**Postconditions**
- Size is available for display in Timeline and, where relevant, Statistics.

**User Actions**
- User selects a Size value while logging an applicable diaper entry.

**System Behaviour**
- The system SHALL present Size as an optional selection field on applicable diaper entry types.
- The system SHALL store the selected Size value with the diaper record.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SIZE-01 | Size, if provided, must be one of Small / Medium / Large. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A (optional field) | N/A |

**Success Conditions**
- Size, when provided, is accurately stored and displayed with the corresponding diaper entry.

---

### 10.9.6 Color

**Purpose**
To capture the observed color of diaper contents where relevant, primarily for Poop and Mixed entries.

**Description**
Color is a shared attribute available on Poop and Mixed diaper entries (Sections 10.9.2–10.9.3), recorded via a defined selection of common color categories to support informational awareness of digestive health trends.

**Inputs**
- User selection of Color from a defined set (e.g., Yellow, Brown, Green, Black, Red, White/Pale, Other).

**Outputs**
- Color value stored as part of the associated diaper entry.

**Preconditions**
- User is logging a Poop or Mixed diaper entry.

**Postconditions**
- Color is available for display in Timeline and, where configured, triggers informational notes (see Section 10.9.2).

**User Actions**
- User selects a Color value while logging an applicable diaper entry.

**System Behaviour**
- The system SHALL present Color as an optional selection field on Poop and Mixed diaper entry types.
- The system SHALL store the selected Color value with the diaper record.
- The system SHOULD display a non-diagnostic informational note for colors commonly associated with recommended pediatric follow-up (e.g., Red, White/Pale, Black outside of the newborn meconium period), consistent with AI Assistant safety principles.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-COLOR-01 | Color, if provided, must be one of the defined selection values. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A (optional field) | N/A |

**Success Conditions**
- Color, when provided, is accurately stored, displayed, and (where applicable) accompanied by an appropriate informational note.

---

### 10.9.7 Notes

**Purpose**
To allow users to add free-form contextual detail to any diaper change entry.

**Description**
Notes is a shared, optional free-text attribute available across all diaper entry types (Pee, Poop, Mixed, Dry), allowing caregivers to capture context not covered by structured fields (e.g., "slight rash observed").

**Inputs**
- Free-text user input.

**Outputs**
- Notes text stored as part of the associated diaper entry.

**Preconditions**
- User is logging any diaper entry type.

**Postconditions**
- Notes text is available for display in Timeline and Search (addressed in a later part of this document).

**User Actions**
- User enters free-text notes while logging a diaper entry.

**System Behaviour**
- The system SHALL present Notes as an optional free-text field on all diaper entry types.
- The system SHALL store Notes text with the diaper record and make it searchable via the Search module.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DNOTE-01 | Notes text, if provided, must not exceed the defined maximum character length. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Notes exceeds character limit | Display character count and prevent submission until within limit. |

**Success Conditions**
- Notes, when provided, are accurately stored, displayed, and searchable.

---

### 10.9.8 History (Timeline)

**Purpose**
To provide a complete, chronological record of all diaper change events for the active baby.

**Description**
Diaper History (Timeline) consolidates all diaper entry types (Pee, Poop, Mixed, Dry) into a filterable, chronological view, allowing users to review recent and past changes.

**Inputs**
- All persisted diaper entry records for the active baby.

**Outputs**
- A chronological, filterable Timeline of diaper entries, each showing Type, Timestamp, Size, Color, and Notes as applicable.

**Preconditions**
- At least one diaper entry has been logged.

**Postconditions**
- All logged diaper entries remain accessible for review, editing, and deletion.

**User Actions**
1. User navigates to Diaper Tracker Timeline/History.
2. User filters/sorts by type or date range.
3. User taps an entry to view, edit, or delete it.

**System Behaviour**
- The system SHALL display diaper entries in reverse-chronological order by default.
- The system SHALL allow filtering by Type (Pee, Poop, Mixed, Dry) and date range.
- The system SHALL allow editing and deletion of existing entries, subject to role permission.
- The system SHALL update Daily/Weekly Statistics (Sections 10.9.9–10.9.10) immediately upon any create/edit/delete action.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DHIST-01 | Diaper Timeline must only display entries belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- All diaper entries are accurately, completely, and promptly reflected in the Timeline.

---

### 10.9.9 Daily Statistics

**Purpose**
To provide an automatically calculated summary of diaper change activity for the current day.

**Description**
Daily Statistics aggregate the current day's diaper entries into summary figures, including total change count and per-type counts (Pee, Poop, Mixed, Dry).

**Inputs**
- All diaper entry records timestamped within the current calendar day for the active baby.

**Outputs**
- Computed Daily Statistics values (Total Changes, Pee Count, Poop Count, Mixed Count, Dry Count).

**Preconditions**
- At least one diaper entry exists for the current day.

**Postconditions**
- User has an accurate current-day diaper summary.

**User Actions**
- User views Daily Statistics within Diaper Tracker or Dashboard Daily Summary.

**System Behaviour**
- The system SHALL calculate Total Changes as the count of all diaper entries logged for the current day.
- The system SHALL calculate per-type counts for Pee, Poop, Mixed, and Dry, applying the combined-counting rule defined in Section 10.9.3 for Mixed entries.
- The system SHALL recalculate these values immediately upon any relevant create/edit/delete action.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DDS-01 | Daily Statistics must only include entries belonging to the active baby profile and timestamped within the current calendar day. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No entries logged today | Display zero-value state. |

**Success Conditions**
- Daily Statistics accurately reflect all diaper activity logged for the current day at all times.

---

### 10.9.10 Weekly Statistics

**Purpose**
To provide an automatically calculated summary of diaper change activity and trends over the trailing seven-day period.

**Description**
Weekly Statistics aggregate diaper entries from the past seven days, presenting total and average daily counts per type, supporting trend awareness (e.g., noticeably reduced wet-diaper frequency, which may warrant caregiver attention).

**Inputs**
- All diaper entry records within the trailing seven-day window for the active baby.

**Outputs**
- Computed Weekly Statistics values and, where applicable, a day-by-day breakdown per type.

**Preconditions**
- At least one diaper entry exists within the trailing seven-day window.

**Postconditions**
- User has an accurate weekly diaper trend summary.

**User Actions**
- User views Weekly Statistics within Diaper Tracker or Reports.

**System Behaviour**
- The system SHALL calculate Weekly Statistics using a rolling seven-day window ending on the current date by default.
- The system SHALL present both aggregate totals and per-type daily breakdowns within the week.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DWS-01 | Weekly Statistics must only include entries belonging to the active baby profile and within the selected seven-day window. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for the selected week | Display "Not enough data yet" or zero-value state as appropriate. |

**Success Conditions**
- Weekly Statistics accurately reflect diaper activity across the selected seven-day window.

---

## 10.10 Vaccination Management

### 10.10.1 Vaccination Schedule

**Purpose**
To provide a structured, age-based schedule of recommended immunizations for the active baby.

**Description**
The Vaccination Schedule presents the full set of recommended vaccines for the baby's age, pre-populated from a maintained reference schedule at baby registration and adjustable for regional or pediatrician-directed variation.

**Inputs**
- Baby's Birth Date (from Section 10.3.2).
- Selected regional schedule template (Settings, Section 10.21).
- Manual additions/adjustments by the user.

**Outputs**
- A structured list of scheduled vaccinations with due dates, derived from the baby's age and the selected reference schedule.

**Preconditions**
- Baby Registration (Section 10.3) is complete, including Birth Information.

**Postconditions**
- A complete, age-appropriate vaccination schedule exists for the baby, ready to populate Upcoming/Completed/Pending/Missed views (Sections 10.10.2–10.10.5).

**User Actions**
1. User navigates to Vaccination Management upon completing Baby Registration or at any later time.
2. User reviews the auto-generated schedule.
3. User may add custom vaccine entries or adjust due dates per pediatrician guidance.

**System Behaviour**
- The system SHALL generate an initial vaccination schedule automatically based on the baby's Birth Date and the selected regional reference schedule.
- The system SHALL allow the user to add, edit, or remove individual scheduled vaccine entries.
- The system SHALL recalculate due dates if the baby's Birth Date is corrected after initial registration.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VS-01 | Every scheduled vaccine entry must have a Vaccine Name and a Due Date. |
| VR-VS-02 | Due Date must be calculable relative to a valid Birth Date. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No regional schedule template available for the user's locale | Fall back to a default general schedule and notify the user that regional customization is unavailable. |
| Manual entry missing required fields | Prevent save and display inline validation error. |

**Success Conditions**
- A complete, accurate, age-based vaccination schedule is generated and available for the baby profile.

---

### 10.10.2 Upcoming Vaccinations

**Purpose**
To clearly surface vaccinations that are due within a near-future window, supporting proactive scheduling.

**Description**
Upcoming Vaccinations filters the Vaccination Schedule (Section 10.10.1) to show entries with a Due Date in the future, ordered chronologically, distinct from Completed, Pending, and Missed entries.

**Inputs**
- Vaccination Schedule entries with Due Date in the future and Status ≠ Completed.

**Outputs**
- A chronologically ordered list of upcoming vaccinations, each showing Vaccine Name, Due Date, and days remaining.

**Preconditions**
- A Vaccination Schedule exists (Section 10.10.1).

**Postconditions**
- User has clear visibility into vaccinations due soon.

**User Actions**
1. User navigates to the Upcoming tab within Vaccination Management.
2. User taps an entry to view detail or mark it Completed.

**System Behaviour**
- The system SHALL classify a schedule entry as Upcoming when its Due Date is in the future and its Status is not Completed.
- The system SHALL sort Upcoming entries by nearest Due Date first.
- The system SHALL visually flag entries due within a configurable near-term window (e.g., next 7 days).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-UV-01 | An entry must appear in exactly one of Upcoming, Pending, Missed, or Completed at any given time (mutually exclusive status). |

**Error Handling**

| Scenario | System Response |
|---|---|
| No upcoming vaccinations | Display empty-state message, e.g., "No upcoming vaccinations." |

**Success Conditions**
- Upcoming Vaccinations accurately and exclusively lists all future, non-completed schedule entries.

---

### 10.10.3 Completed Vaccinations

**Purpose**
To maintain a clear record of vaccinations that have been administered.

**Description**
Completed Vaccinations lists all schedule entries the user has explicitly marked as administered, capturing the actual administration date, distinct from the originally scheduled Due Date.

**Inputs**
- User action marking a scheduled entry as Completed, with Administration Date.

**Outputs**
- Entry moved to Completed status, retained with both original Due Date and actual Administration Date.

**Preconditions**
- A Vaccination Schedule entry exists.

**Postconditions**
- The entry is permanently recorded as Completed and included in Vaccination History (Section 10.10.10) and Progress Tracking (Section 10.10.11).

**User Actions**
1. User selects a schedule entry (typically from Upcoming or Pending).
2. User marks it "Completed" and enters the Administration Date (and optionally administering doctor/hospital).
3. User saves.

**System Behaviour**
- The system SHALL require an Administration Date when marking an entry Completed.
- The system SHALL retain the original Due Date alongside the Administration Date for historical accuracy.
- The system SHALL update Progress Tracking figures immediately upon completion.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CV-01 | Administration Date must not be a future date. |
| VR-CV-02 | An entry marked Completed must not simultaneously appear in Upcoming, Pending, or Missed lists. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Administration Date left empty | Prevent save and display inline validation error. |
| Administration Date in the future | Display validation error and prevent save. |

**Success Conditions**
- Completed vaccinations are accurately recorded with administration detail and reflected in History and Progress Tracking.

---

### 10.10.4 Pending Vaccinations

**Purpose**
To identify vaccinations that are due but not yet overdue beyond the acceptable grace window, requiring attention but not yet classified as Missed.

**Description**
Pending Vaccinations represents an intermediate status for entries whose Due Date has passed but remain within a configurable grace period before being escalated to Missed (Section 10.10.5).

**Inputs**
- Vaccination Schedule entries with Due Date in the past, within the grace period, and Status ≠ Completed.

**Outputs**
- A list of Pending vaccinations, each showing Vaccine Name, original Due Date, and days overdue.

**Preconditions**
- A Vaccination Schedule exists and at least one entry's Due Date has passed.

**Postconditions**
- User has visibility into vaccinations requiring prompt attention before they are classified as Missed.

**User Actions**
1. User navigates to the Pending tab within Vaccination Management.
2. User marks the entry Completed or takes note to schedule an appointment.

**System Behaviour**
- The system SHALL classify a schedule entry as Pending when its Due Date has passed but remains within the configured grace period (e.g., 14 days) and Status is not Completed.
- The system SHALL automatically transition a Pending entry to Missed status once the grace period elapses without completion.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PV-01 | The grace period duration must be consistently applied across all vaccine entries unless explicitly overridden per entry. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No pending vaccinations | Display empty-state message. |

**Success Conditions**
- Pending Vaccinations accurately reflects overdue-but-within-grace-period entries and correctly transitions them to Missed when appropriate.

---

### 10.10.5 Missed Vaccinations

**Purpose**
To clearly flag vaccinations that have exceeded the acceptable grace period without being administered, prompting urgent caregiver attention.

**Description**
Missed Vaccinations lists schedule entries whose grace period (Section 10.10.4) has elapsed without a Completed status, presented with elevated visual emphasis to prompt action.

**Inputs**
- Vaccination Schedule entries transitioned automatically from Pending status upon grace period expiry.

**Outputs**
- A list of Missed vaccinations, each showing Vaccine Name, original Due Date, and days overdue, with elevated visual/alert styling.

**Preconditions**
- At least one Pending entry has exceeded its grace period.

**Postconditions**
- User is clearly alerted to overdue vaccinations requiring immediate scheduling.

**User Actions**
1. User navigates to the Missed tab within Vaccination Management.
2. User marks the entry Completed once administered, or schedules an appointment (Section 10.10.8).

**System Behaviour**
- The system SHALL automatically transition entries from Pending to Missed upon grace period expiry (Section 10.10.4).
- The system SHALL apply elevated visual/alert styling (e.g., red indicator) to Missed entries, consistent with accessibility color-indicator requirements addressed later in this document.
- The system SHALL trigger a Reminder Notification (Section 10.10.9) upon transition to Missed status.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MV-01 | An entry must remain in Missed status until explicitly marked Completed; it must not silently revert to Pending or Upcoming. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No missed vaccinations | Display empty-state message. |

**Success Conditions**
- Missed Vaccinations accurately and persistently flags overdue entries until resolved.

---

### 10.10.6 Doctor Information

**Purpose**
To associate a specific doctor with a vaccination entry or appointment for reference and continuity of care.

**Description**
Doctor Information captures the name and contact detail of the doctor administering or overseeing a given vaccination, either inherited from the baby's default Doctor (Section 10.13) or specified per entry.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Doctor Name | Text | No |
| Doctor Contact (phone/email) | Text | No |

**Outputs**
- Doctor Information stored as part of the vaccination entry.

**Preconditions**
- A vaccination schedule entry exists.

**Postconditions**
- Doctor Information is displayed alongside the vaccination entry in History and detail views.

**User Actions**
1. User opens a vaccination entry.
2. User enters or confirms Doctor Name/Contact, or accepts the baby profile's default Doctor.

**System Behaviour**
- The system SHALL pre-fill Doctor Information from the baby profile's default Doctor (Section 10.13.6) where available, allowing per-entry override.
- The system SHALL store any per-entry override independently of the baby profile default.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DOC-01 | Doctor Contact, if provided, must conform to a valid phone or email format. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid contact format entered | Display inline validation error. |

**Success Conditions**
- Doctor Information is accurately associated with and displayed for each vaccination entry.

---

### 10.10.7 Hospital Information

**Purpose**
To associate a specific hospital or clinic with a vaccination entry for reference and continuity of care.

**Description**
Hospital Information captures the name and location of the hospital/clinic administering a given vaccination, either inherited from the baby's default Hospital (Section 10.13) or specified per entry.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Hospital/Clinic Name | Text | No |
| Address | Text | No |

**Outputs**
- Hospital Information stored as part of the vaccination entry.

**Preconditions**
- A vaccination schedule entry exists.

**Postconditions**
- Hospital Information is displayed alongside the vaccination entry in History and detail views.

**User Actions**
1. User opens a vaccination entry.
2. User enters or confirms Hospital/Clinic Name and Address, or accepts the baby profile's default Hospital.

**System Behaviour**
- The system SHALL pre-fill Hospital Information from the baby profile's default Hospital (Section 10.13.5) where available, allowing per-entry override.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-HOSP-01 | Hospital/Clinic Name, if provided, must not be empty text. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A (optional field) | N/A |

**Success Conditions**
- Hospital Information is accurately associated with and displayed for each vaccination entry.

---

### 10.10.8 Appointment Scheduling

**Purpose**
To allow users to schedule a specific date/time appointment for an upcoming or pending vaccination.

**Description**
Appointment Scheduling allows the user to attach a concrete appointment date/time to a vaccination entry, distinct from the general Due Date, triggering an associated Reminder Notification (Section 10.10.9).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Appointment Date/Time | Timestamp | Yes |
| Doctor/Hospital (Sections 10.10.6–10.10.7) | Text | No |

**Outputs**
- An appointment record linked to the vaccination entry.
- A scheduled Reminder Notification ahead of the appointment.

**Preconditions**
- A vaccination schedule entry exists (typically Upcoming or Pending).

**Postconditions**
- The vaccination entry has an associated appointment, and a reminder is scheduled.

**User Actions**
1. User opens a vaccination entry.
2. User taps "Schedule Appointment" and selects date/time.
3. User saves.

**System Behaviour**
- The system SHALL allow at most one active appointment per vaccination entry.
- The system SHALL automatically schedule a Reminder Notification (Section 10.10.9) relative to the appointment time (e.g., one day before).
- The system SHALL allow rescheduling or cancellation of the appointment, updating or cancelling the associated reminder accordingly.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-APPT-01 | Appointment Date/Time must not be in the past at the time of scheduling. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Appointment date/time in the past | Display validation error and prevent save. |

**Success Conditions**
- Appointments are accurately scheduled, displayed, and paired with a corresponding reminder.

---

### 10.10.9 Reminder Notifications

**Purpose**
To proactively alert users of upcoming, due, and overdue vaccinations.

**Description**
Reminder Notifications deliver alerts for vaccinations approaching their Due Date, scheduled appointments, and transitions into Missed status, using the Notification System (Section 10.17) with accessibility-first (visual/haptic) delivery.

**Inputs**
- Vaccination Schedule Due Dates, scheduled Appointment times, and Missed status transitions.

**Outputs**
- Push and/or local notifications delivered at configured intervals ahead of relevant dates.

**Preconditions**
- Notification permissions have been granted (Section 10.17).
- A relevant vaccination schedule entry or appointment exists.

**Postconditions**
- User is alerted in advance of and upon relevant vaccination-related events.

**User Actions**
- User receives and may tap the notification to navigate directly to the relevant vaccination entry.

**System Behaviour**
- The system SHALL generate reminders at configurable intervals ahead of a vaccination Due Date (e.g., 7 days, 1 day).
- The system SHALL generate a reminder ahead of any scheduled Appointment (Section 10.10.8).
- The system SHALL generate an alert immediately upon an entry transitioning to Missed status (Section 10.10.5).
- The system SHALL deliver all reminders through the Notification System, applying visual and haptic delivery consistent with Accessibility Requirements (addressed later in this document).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VREM-01 | A reminder must not be generated for an entry already marked Completed. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Notification permission not granted | Fall back to in-app banner alerts on next app open, and prompt the user to enable notifications. |

**Success Conditions**
- Users reliably receive timely reminders for all upcoming, appointment-linked, and missed vaccinations.

---

### 10.10.10 Vaccination History

**Purpose**
To provide a complete, chronological record of all vaccination activity — scheduled, completed, and missed — for the active baby.

**Description**
Vaccination History consolidates the full lifecycle of every schedule entry, including status transitions and administration detail, into a single reviewable timeline, useful for pediatric visits.

**Inputs**
- All Vaccination Schedule entries and their status history for the active baby.

**Outputs**
- A chronological, filterable list of all vaccination entries with full status and administration detail.

**Preconditions**
- A Vaccination Schedule exists.

**Postconditions**
- User (and, where exported, a pediatrician) has full visibility into the baby's vaccination history.

**User Actions**
1. User navigates to Vaccination History.
2. User filters by status (Upcoming/Completed/Pending/Missed) or date range.
3. User may export the history (see Reports and Analytics, Section 10.16).

**System Behaviour**
- The system SHALL display all vaccination entries regardless of status, with clear status indicators.
- The system SHALL allow filtering and sorting by status and date.
- The system SHALL retain full history even after an entry is marked Completed.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VHIST-01 | Vaccination History must only display entries belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- Vaccination History accurately and completely reflects the baby's full immunization record.

---

### 10.10.11 Progress Tracking

**Purpose**
To provide a summarized indicator of overall vaccination completion progress relative to the full schedule.

**Description**
Progress Tracking presents an aggregate completion indicator (e.g., "8 of 12 vaccinations completed," or a percentage/progress bar) derived from the Vaccination Schedule and its current status breakdown.

**Inputs**
- Count of Completed entries versus total scheduled entries for the active baby.

**Outputs**
- A visual progress indicator (percentage and/or progress bar) with a breakdown by status.

**Preconditions**
- A Vaccination Schedule exists.

**Postconditions**
- User has an at-a-glance understanding of overall vaccination completion status.

**User Actions**
- User views the Progress Tracking indicator within Vaccination Management or the Dashboard.

**System Behaviour**
- The system SHALL calculate overall progress as (Completed entries ÷ Total scheduled entries) × 100%.
- The system SHALL update the progress indicator immediately upon any status change.
- The system SHALL visually distinguish Completed, Upcoming, Pending, and Missed proportions within the indicator where feasible (e.g., segmented progress bar).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VPROG-01 | Progress percentage must be recalculated whenever the underlying schedule or status data changes. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No schedule entries exist | Display "No vaccination schedule yet" rather than a misleading 0% or undefined value. |

**Success Conditions**
- Progress Tracking accurately and immediately reflects the baby's current vaccination completion status.

---

## 10.11 Milestone Tracking

### 10.11.1 Development Timeline

**Purpose**
To present the full set of trackable developmental milestones in a structured, age-ordered timeline.

**Description**
The Development Timeline lists standard milestones (e.g., First Smile, Roll Over, Sit, Crawl, Stand, Walk, First Word) ordered by expected age, showing achieved and not-yet-achieved status for the active baby.

**Inputs**
- Standard milestone reference list (Expected Age ranges, Section 10.11.2).
- Baby's Birth Date (for age-relative ordering and status).

**Outputs**
- An age-ordered timeline of milestones with achievement status.

**Preconditions**
- Baby Registration is complete.

**Postconditions**
- User can view the full milestone landscape for the baby's current and upcoming developmental stages.

**User Actions**
1. User navigates to Milestone Tracking.
2. User views the Development Timeline.
3. User selects a milestone to record or review Achievement Date, Photos, Videos, and Notes.

**System Behaviour**
- The system SHALL present milestones in chronological order of Expected Age.
- The system SHALL visually distinguish Achieved, Due Soon, and Not Yet Due milestones.
- The system SHALL allow the user to add custom, non-standard milestones to the timeline.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DT-01 | Every timeline entry (standard or custom) must have an associated Expected Age or explicit "custom/no expected age" designation. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Timeline fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- The Development Timeline accurately and completely reflects standard and custom milestones with correct status for the active baby.

---

### 10.11.2 Expected Age

**Purpose**
To provide caregivers with general guidance on the typical age range at which a given milestone is expected, supporting awareness without implying strict diagnostic timelines.

**Description**
Expected Age is a reference attribute on each standard milestone, drawn from general pediatric developmental guidance (Section 5.2), displayed as a range (e.g., "4–6 months") rather than a single fixed date.

**Inputs**
- Standard milestone reference data (maintained content set).

**Outputs**
- Displayed Expected Age range alongside each milestone in the Development Timeline.

**Preconditions**
- A standard milestone exists in the reference set.

**Postconditions**
- User has non-diagnostic, general guidance on typical milestone timing.

**User Actions**
- User views Expected Age ranges while browsing the Development Timeline.

**System Behaviour**
- The system SHALL display Expected Age as a range, not a single definitive date.
- The system SHALL include a general disclaimer that expected ranges are approximate and that variation is normal, consistent with AI Safety Disclaimer principles (Section 10.15.9).
- The system SHALL NOT flag a milestone as "delayed" in alarming language; it MAY neutrally indicate "Due Soon" or "Typically achieved by now" framing.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-EA-01 | Expected Age ranges must be sourced from the maintained reference content set (Section 5.2), not generated dynamically per baby. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No Expected Age defined for a custom milestone | Omit the Expected Age display for that entry without error. |

**Success Conditions**
- Expected Age ranges are consistently and non-alarmingly displayed for all standard milestones.

---

### 10.11.3 Achievement Date

**Purpose**
To record the actual date on which the baby achieved a given milestone.

**Description**
Achievement Date captures the caregiver-reported date a milestone was reached, used to mark the milestone Achieved and to compute Progress Percentage (Section 10.11.7).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Achievement Date | Date | Yes (when marking Achieved) |

**Outputs**
- Milestone entry updated to Achieved status with the recorded date.

**Preconditions**
- A milestone entry exists in the Development Timeline.

**Postconditions**
- The milestone is marked Achieved and included in Milestone History (Section 10.11.8).

**User Actions**
1. User selects a milestone.
2. User taps "Mark as Achieved" and enters the Achievement Date.
3. User saves.

**System Behaviour**
- The system SHALL require an Achievement Date when marking a milestone Achieved.
- The system SHALL NOT allow an Achievement Date earlier than the baby's Birth Date.
- The system SHALL immediately update Progress Percentage and Milestone History upon save.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-AD-01 | Achievement Date must not be a future date. |
| VR-AD-02 | Achievement Date must not be earlier than the baby's Birth Date. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Achievement Date left empty | Prevent save and display inline validation error. |
| Achievement Date outside valid range | Display validation error and prevent save. |

**Success Conditions**
- Achievement Date is accurately recorded and correctly updates milestone status, History, and Progress Percentage.

---

### 10.11.4 Photos

**Purpose**
To allow caregivers to attach photographic evidence/memories to a milestone entry.

**Description**
Photos allows one or more images to be attached to a milestone (achieved or in-progress), stored alongside the entry and also surfaced within the Gallery module (Section 10.12) under milestone categorization.

**Inputs**
- User-selected or captured image file(s).

**Outputs**
- Photo(s) stored and linked to the milestone entry and to the Gallery.

**Preconditions**
- Camera or storage access permission has been granted.
- A milestone entry exists.

**Postconditions**
- Attached photos are viewable from both the milestone entry and the Gallery's milestone category.

**User Actions**
1. User opens a milestone entry.
2. User taps "Add Photo" and captures or selects an image.
3. User saves.

**System Behaviour**
- The system SHALL allow attachment of one or more photos per milestone entry.
- The system SHALL store attached photos in a manner accessible to both the milestone detail view and the Gallery's automatic milestone categorization (Section 10.12).
- The system SHALL apply the same format/size validation as Gallery Photo Upload (Section 10.12.1).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MPH-01 | Photo format and size must conform to VR-GAL-PH-01 (Section 10.12.1). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Unsupported format/size | Display error consistent with Gallery Photo Upload handling. |

**Success Conditions**
- Photos are successfully attached to the milestone and correctly surfaced in the Gallery.

---

### 10.11.5 Videos

**Purpose**
To allow caregivers to attach video evidence/memories to a milestone entry.

**Description**
Videos allows one or more video clips to be attached to a milestone entry, stored alongside the entry and also surfaced within the Gallery module under milestone categorization.

**Inputs**
- User-selected or captured video file(s).

**Outputs**
- Video(s) stored and linked to the milestone entry and to the Gallery.

**Preconditions**
- Camera or storage access permission has been granted.
- A milestone entry exists.

**Postconditions**
- Attached videos are viewable from both the milestone entry and the Gallery's milestone category.

**User Actions**
1. User opens a milestone entry.
2. User taps "Add Video" and captures or selects a video.
3. User saves.

**System Behaviour**
- The system SHALL allow attachment of one or more videos per milestone entry, subject to a maximum duration/file size limit.
- The system SHALL apply the same format/size validation as Gallery Video Upload (Section 10.12.2).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MVID-01 | Video format, duration, and size must conform to VR-GAL-VID-01 (Section 10.12.2). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Unsupported format or size/duration exceeded | Display error consistent with Gallery Video Upload handling. |

**Success Conditions**
- Videos are successfully attached to the milestone and correctly surfaced in the Gallery.

---

### 10.11.6 Notes

**Purpose**
To allow caregivers to record free-form context or memories associated with a milestone.

**Description**
Notes is an optional free-text field on each milestone entry, allowing caregivers to capture context (e.g., "said 'mama' for the first time during dinner").

**Inputs**
- Free-text user input.

**Outputs**
- Notes text stored with the milestone entry.

**Preconditions**
- A milestone entry exists.

**Postconditions**
- Notes are viewable and searchable (Section 10.19) alongside the milestone entry.

**User Actions**
- User enters free-text notes while viewing/editing a milestone entry.

**System Behaviour**
- The system SHALL store Notes text with the milestone record and make it searchable via the Search module.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MNOTE-01 | Notes text, if provided, must not exceed the defined maximum character length. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Notes exceeds character limit | Display character count and prevent submission until within limit. |

**Success Conditions**
- Notes are accurately stored, displayed, and searchable.

---

### 10.11.7 Progress Percentage

**Purpose**
To provide a summarized indicator of overall developmental milestone progress relative to the full standard milestone set for the baby's current age.

**Description**
Progress Percentage presents an aggregate completion indicator (e.g., "6 of 10 age-appropriate milestones achieved") derived from the Development Timeline and Achievement Date data.

**Inputs**
- Count of Achieved milestones versus total applicable milestones for the baby's current age range.

**Outputs**
- A visual progress indicator (percentage and/or progress bar).

**Preconditions**
- A Development Timeline exists for the baby.

**Postconditions**
- User has an at-a-glance understanding of overall developmental milestone progress.

**User Actions**
- User views the Progress Percentage indicator within Milestone Tracking or the Dashboard.

**System Behaviour**
- The system SHALL calculate Progress Percentage as (Achieved milestones ÷ applicable milestones for current age) × 100%.
- The system SHALL update the indicator immediately upon any Achievement Date change.
- The system SHALL present this indicator using neutral, non-alarming framing consistent with Section 10.11.2.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MPROG-01 | Progress Percentage must be recalculated whenever the underlying milestone or Achievement Date data changes. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No applicable milestones defined for the baby's age | Display "Not applicable yet" rather than an undefined value. |

**Success Conditions**
- Progress Percentage accurately and immediately reflects the baby's current developmental milestone status.

---

### 10.11.8 Milestone History

**Purpose**
To provide a complete, chronological record of all achieved milestones for the active baby.

**Description**
Milestone History lists all milestones marked Achieved, ordered by Achievement Date, with attached Photos, Videos, and Notes, forming a keepsake developmental record.

**Inputs**
- All milestone entries with a recorded Achievement Date for the active baby.

**Outputs**
- A chronological list of achieved milestones with full attached detail.

**Preconditions**
- At least one milestone has been marked Achieved.

**Postconditions**
- All achieved milestones remain accessible for review, editing, and deletion.

**User Actions**
1. User navigates to Milestone History.
2. User reviews past achieved milestones.
3. User taps an entry to view full detail, edit, or delete it.

**System Behaviour**
- The system SHALL display achieved milestones in chronological order by Achievement Date.
- The system SHALL allow editing (e.g., correcting Achievement Date) and deletion, subject to role permission.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MHIST-01 | Milestone History must only display entries belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- Milestone History accurately and completely reflects the baby's achieved developmental milestones.

---

## 10.12 Gallery

### 10.12.1 Photo Upload

**Purpose**
To allow users to add photos of the baby to the application's media library.

**Description**
Photo Upload allows capture via device camera or selection from the device photo library, storing the image for display within the Gallery, with automatic categorization (Section 10.12.3) and optional linkage to milestones.

**Inputs**
- User-captured or selected image file.

**Outputs**
- A stored photo record, categorized and viewable within the Gallery.

**Preconditions**
- Camera or storage access permission has been granted.
- An active baby profile is selected.

**Postconditions**
- The photo is available in Gallery Timeline and Grid views.

**User Actions**
1. User navigates to Gallery.
2. User taps "Add Photo" and captures or selects an image.
3. User optionally tags the photo with a date, milestone, or caption.
4. User saves.

**System Behaviour**
- The system SHALL store the uploaded photo locally immediately, queuing Cloud Backup (Section 10.12.7) per Offline Mode rules.
- The system SHALL automatically categorize the photo by Month and, where linked, by Milestone.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GAL-PH-01 | Photo must be in a supported image format (e.g., JPEG, PNG, HEIC) and must not exceed the defined maximum file size. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Unsupported format | Display "Unsupported file format" with accepted formats listed. |
| File exceeds size limit | Display "File too large" message. |
| Storage permission denied | Display accessible explanation and link to device settings. |

**Success Conditions**
- Photo is successfully stored, categorized, and displayed within the Gallery.

---

### 10.12.2 Video Upload

**Purpose**
To allow users to add videos of the baby to the application's media library.

**Description**
Video Upload allows capture via device camera or selection from the device video library, storing the video for playback within the Gallery, with automatic categorization and optional linkage to milestones.

**Inputs**
- User-captured or selected video file.

**Outputs**
- A stored video record, categorized and viewable/playable within the Gallery.

**Preconditions**
- Camera or storage access permission has been granted.
- An active baby profile is selected.

**Postconditions**
- The video is available in Gallery Timeline and Grid views.

**User Actions**
1. User navigates to Gallery.
2. User taps "Add Video" and captures or selects a video.
3. User optionally tags the video with a date, milestone, or caption.
4. User saves.

**System Behaviour**
- The system SHALL store the uploaded video locally immediately, queuing Cloud Backup per Offline Mode rules.
- The system SHALL automatically categorize the video by Month and, where linked, by Milestone.
- The system SHALL generate a thumbnail preview for Grid View display.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GAL-VID-01 | Video must be in a supported format (e.g., MP4, MOV) and must not exceed the defined maximum file size/duration. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Unsupported format | Display "Unsupported file format" with accepted formats listed. |
| File exceeds size/duration limit | Display appropriate error message specifying the limit. |

**Success Conditions**
- Video is successfully stored, categorized, thumbnailed, and playable within the Gallery.

---

### 10.12.3 Timeline View

**Purpose**
To present Gallery media in reverse-chronological order, organized by capture/upload date.

**Description**
Timeline View displays photos and videos grouped by Month (per the automatic categorization defined in the System Scope), allowing users to browse media in the order it was captured.

**Inputs**
- All stored photo/video records for the active baby, with associated timestamps.

**Outputs**
- A scrollable, chronologically grouped (by Month) media view.

**Preconditions**
- At least one photo or video has been uploaded.

**Postconditions**
- User can browse all media chronologically.

**User Actions**
1. User navigates to Gallery and selects Timeline View.
2. User scrolls through month-grouped media.
3. User taps a media item to view it in full detail.

**System Behaviour**
- The system SHALL group media by calendar month of capture/upload date.
- The system SHALL order groups reverse-chronologically, with items within each group also reverse-chronological.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-TV-01 | Timeline View must only display media belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No media uploaded yet | Display empty-state guidance prompting the user to add their first photo/video. |

**Success Conditions**
- Timeline View accurately and completely reflects all uploaded media in correct chronological grouping.

---

### 10.12.4 Grid View

**Purpose**
To present Gallery media in a compact, visual grid layout for rapid browsing.

**Description**
Grid View displays photo/video thumbnails in a uniform grid, optimized for quickly scanning a large volume of media, as an alternative to Timeline View.

**Inputs**
- All stored photo/video records for the active baby.

**Outputs**
- A grid layout of media thumbnails.

**Preconditions**
- At least one photo or video has been uploaded.

**Postconditions**
- User can rapidly browse all media in a compact visual layout.

**User Actions**
1. User navigates to Gallery and selects Grid View.
2. User scrolls/taps thumbnails to view individual media in full detail.

**System Behaviour**
- The system SHALL render thumbnails for all photos and generated video thumbnails in a uniform grid.
- The system SHALL support toggling between Grid View and Timeline View from the same Gallery screen.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GV-01 | Grid View must only display media belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Thumbnail generation failure for a given item | Display a generic placeholder thumbnail with a broken-media indicator, without blocking the rest of the grid. |

**Success Conditions**
- Grid View accurately and completely reflects all uploaded media in a performant, scrollable layout.

---

### 10.12.5 Search

**Purpose**
To allow users to locate specific Gallery media using text-based search.

**Description**
Gallery Search allows querying media by associated caption, tag, linked milestone name, or date, returning matching results within the Gallery context. (This is distinct from, but consistent with, the application-wide Search module, Section 10.19.)

**Inputs**
- User-entered search query text.

**Outputs**
- A filtered list/grid of media matching the query.

**Preconditions**
- At least one photo or video with searchable metadata (caption, tag, milestone link) exists.

**Postconditions**
- User is presented with matching media results.

**User Actions**
1. User taps the search control within Gallery.
2. User enters a query.
3. User reviews filtered results.

**System Behaviour**
- The system SHALL search across media captions, tags, and linked milestone names.
- The system SHALL update results as the user types (incremental search), where performant to do so.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GSRCH-01 | Search results must only include media belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No matching results | Display "No media found" empty state. |

**Success Conditions**
- Gallery Search accurately and promptly returns all matching media for a given query.

---

### 10.12.6 Filter

**Purpose**
To allow users to narrow displayed Gallery media by structured criteria.

**Description**
Filter allows the user to constrain Timeline or Grid View results by criteria such as Media Type (Photo/Video), Month, or Linked Milestone, independent of free-text Search (Section 10.12.5).

**Inputs**
- User-selected filter criteria (Media Type, Month, Milestone).

**Outputs**
- A filtered list/grid of media matching the selected criteria.

**Preconditions**
- At least one photo or video exists.

**Postconditions**
- User is presented with media matching the applied filters until cleared.

**User Actions**
1. User taps the Filter control within Gallery.
2. User selects one or more filter criteria.
3. User applies the filter.

**System Behaviour**
- The system SHALL support combining multiple filter criteria (e.g., Video + specific Month).
- The system SHALL persist applied filters during the Gallery session until explicitly cleared or the session ends.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GFILT-01 | Filtered results must only include media belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No media matches the applied filters | Display "No media found for the selected filters" with an option to clear filters. |

**Success Conditions**
- Filter accurately narrows Gallery results to only media matching all selected criteria.

---

### 10.12.7 Cloud Backup

**Purpose**
To ensure Gallery media is durably preserved beyond the local device through cloud storage.

**Description**
Cloud Backup automatically uploads locally stored photos and videos to cloud storage when connectivity is available, ensuring media is recoverable if the device is lost, damaged, or replaced.

**Inputs**
- Locally stored, not-yet-backed-up photo/video records.
- Network connectivity state.

**Outputs**
- Media files persisted to cloud storage, with local records updated to reflect backup status.

**Preconditions**
- User is authenticated.
- Network connectivity is available.

**Postconditions**
- All eligible media is backed up to the cloud, recoverable on any authenticated device.

**User Actions**
- No direct user action required; backup occurs automatically. User may view backup status per item.

**System Behaviour**
- The system SHALL automatically queue newly added media for Cloud Backup.
- The system SHALL upload queued media when network connectivity is available, consistent with Offline Synchronization requirements (Section 10.18).
- The system SHALL indicate backup status (e.g., "Backed up" / "Pending backup") per media item.
- The system SHOULD allow the user to control backup behavior over cellular data versus Wi-Fi only, per Settings (Section 10.21).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GBAK-01 | Media must not be marked "Backed up" until upload is confirmed successful by the cloud storage service. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Upload failure | Retain "Pending backup" status and retry automatically on next available connectivity, consistent with Section 10.18 Error Recovery. |

**Success Conditions**
- All eligible media is reliably and automatically backed up to the cloud, with accurate status reflected to the user.

---

### 10.12.8 Offline Storage

**Purpose**
To ensure Gallery media captured or viewed offline remains fully available without requiring connectivity.

**Description**
Offline Storage ensures all uploaded photos/videos are retained on-device (subject to device storage constraints) and remain viewable, addable, and manageable without an internet connection.

**Inputs**
- Locally stored photo/video files and metadata.

**Outputs**
- Fully functional Gallery browsing, uploading (pending backup), and organization while offline.

**Preconditions**
- Device is offline.

**Postconditions**
- User retains full Gallery functionality; new media queues for Cloud Backup upon reconnection.

**User Actions**
- User uses Gallery normally (upload, browse, search, filter) while offline.

**System Behaviour**
- The system SHALL persist all Gallery media and metadata locally, independent of connectivity.
- The system SHALL allow all Gallery functions (Sections 10.12.1–10.12.6, 10.12.9–10.12.10) to operate fully offline, with Cloud Backup deferred until connectivity is restored.
- The system SHOULD manage local storage usage (e.g., cache eviction for cloud-only-backed older media) to prevent excessive on-device storage consumption, consistent with Section 7.5.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GOFF-01 | No Gallery function other than Cloud Backup itself may be blocked by lack of connectivity. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Local device storage full | Display a clear warning and prevent further local media addition until space is freed or cloud-only storage mode is enabled, if supported. |

**Success Conditions**
- Gallery remains fully usable offline, with no functional degradation beyond deferred cloud backup.

---

### 10.12.9 Delete

**Purpose**
To allow users to remove unwanted media from the Gallery.

**Description**
Delete allows a user to remove one or more photos/videos from local and cloud storage, with a recoverable interim state via Restore (Section 10.12.10) before permanent removal.

**Inputs**
- User selection of one or more media items and confirmation action.

**Outputs**
- Selected media moved to a "recently deleted" state (recoverable) and, after a retention window, permanently removed.

**Preconditions**
- At least one media item exists.
- User holds sufficient role permission (see Section 10.20).

**Postconditions**
- Deleted media is hidden from normal Gallery views but recoverable within the retention window via Restore.

**User Actions**
1. User selects one or more media items.
2. User taps "Delete" and confirms.

**System Behaviour**
- The system SHALL require explicit confirmation before deleting any media item.
- The system SHALL move deleted items to a "recently deleted" holding state for a defined retention window (e.g., 30 days) rather than immediate permanent deletion.
- The system SHALL permanently remove items from local and cloud storage automatically upon retention window expiry.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GDEL-01 | Deletion must require explicit confirmation. |
| VR-GDEL-02 | Only users with appropriate role permission may delete media. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Deletion attempted without sufficient permission | Deny the action and display a permission-denied message. |

**Success Conditions**
- Selected media is reliably moved to the recoverable "recently deleted" state and, subsequently, permanently removed after the retention window.

---

### 10.12.10 Restore

**Purpose**
To allow users to recover media that was previously deleted, within the retention window.

**Description**
Restore allows a user to browse the "recently deleted" holding area (Section 10.12.9) and return one or more items to the active Gallery before permanent removal occurs.

**Inputs**
- User selection of one or more "recently deleted" media items and a restore confirmation action.

**Outputs**
- Selected media returned to normal Gallery Timeline/Grid views.

**Preconditions**
- At least one media item exists within the "recently deleted" retention window.

**Postconditions**
- Restored media is fully reinstated into the active Gallery, including its original categorization and milestone links.

**User Actions**
1. User navigates to the "Recently Deleted" area within Gallery.
2. User selects one or more items.
3. User taps "Restore."

**System Behaviour**
- The system SHALL display remaining retention time for each "recently deleted" item.
- The system SHALL fully reinstate restored items, including original metadata, categorization, and any milestone linkage.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GRES-01 | Restore must only be available within the defined retention window (Section 10.12.9); items past this window are not recoverable through the application. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Attempted restore after retention window has expired | Display "This item can no longer be restored." |

**Success Conditions**
- Selected items are reliably and completely restored to the active Gallery when within the retention window.

---

## 10.13 Baby Profile

### 10.13.1 Baby Details

**Purpose**
To present and allow ongoing management of the baby's core identifying information after initial registration.

**Description**
Baby Details, within the Baby Profile module, displays and allows editing of the same core identity fields captured during Baby Registration (Section 10.3.1) — Baby Name, Gender, Profile Photo, Nickname — as an ongoing profile management surface rather than a one-time onboarding step.

**Inputs**
- Existing Baby Details record; user-submitted edits.

**Outputs**
- Updated Baby Details record.

**Preconditions**
- A baby profile exists (Section 10.3).
- User holds sufficient role permission to view/edit (Section 10.20).

**Postconditions**
- Baby Details reflect the most recently saved values across the application.

**User Actions**
1. User navigates to Baby Profile.
2. User views Baby Details.
3. User taps "Edit" (Section 10.13.9) to modify fields.

**System Behaviour**
- The system SHALL display current Baby Details sourced from the same underlying record established at registration.
- The system SHALL apply the same validation rules as initial registration (VR-BD-01–03, Section 10.3.1) to any edits.
- The system SHALL propagate updated Baby Name/Photo immediately across all views referencing the baby (Dashboard, navigation, switcher).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PBD-01 | Edits must satisfy the same validation rules as initial Baby Details entry (Section 10.3.1). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid edit submitted | Display inline validation error consistent with Section 10.3.1 and prevent save. |

**Success Conditions**
- Baby Details are accurately displayed and, upon valid edits, consistently updated throughout the application.

---

### 10.13.2 Parent Details

**Purpose**
To present and allow management of the parent/account holder information associated with the baby profile.

**Description**
Parent Details displays the relationship role and display name captured during Parent Registration (Section 10.2) for the currently authenticated user, as well as (where permitted) a read-only view of other linked caregivers, cross-referenced with Family Sharing (Section 10.20).

**Inputs**
- Existing Parent profile record; user-submitted edits (for the authenticated user's own record).

**Outputs**
- Updated Parent Details for the authenticated user; a list of other associated caregivers.

**Preconditions**
- Parent Registration is complete (Section 10.2).

**Postconditions**
- Parent Details reflect the most recently saved values.

**User Actions**
1. User navigates to Baby Profile → Parent Details.
2. User views their own role/details and other linked caregivers.
3. User edits their own details, where permitted.

**System Behaviour**
- The system SHALL allow a user to edit only their own Parent Details, not those of other linked caregivers.
- The system SHALL display other linked caregivers' names/roles as read-only, sourced from Family Sharing (Section 10.20).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PPD-01 | Edits must satisfy the same validation rules as initial Parent Registration (Section 10.2). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Attempt to edit another user's Parent Details | Deny the action and display a permission-denied message. |

**Success Conditions**
- Parent Details accurately reflect each caregiver's role, with edits restricted to one's own record.

---

### 10.13.3 Medical Information

**Purpose**
To present and allow ongoing management of the baby's medical information after initial registration.

**Description**
Medical Information, within Baby Profile, displays and allows editing of the fields captured during Baby Registration (Section 10.3.3) — Blood Group, Doctor, Hospital, Allergies, Medical Notes — as an ongoing management surface.

**Inputs**
- Existing Medical Information record; user-submitted edits.

**Outputs**
- Updated Medical Information record.

**Preconditions**
- A baby profile exists.
- User holds sufficient role permission.

**Postconditions**
- Medical Information reflects the most recently saved values, surfaced contextually elsewhere in the application (e.g., feeding allergy warnings).

**User Actions**
1. User navigates to Baby Profile → Medical Information.
2. User views current medical data.
3. User taps "Edit" to modify.

**System Behaviour**
- The system SHALL apply the same validation rules as initial registration (Section 10.3.3) to any edits.
- The system SHALL propagate updated Allergy information immediately to contextual warnings elsewhere in the application.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PMI-01 | Edits must satisfy the same validation rules as initial Medical Information entry (Section 10.3.3). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid edit submitted | Display inline validation error and prevent save. |

**Success Conditions**
- Medical Information is accurately displayed and, upon valid edits, consistently updated throughout the application.

---

### 10.13.4 Growth Information

**Purpose**
To present a summarized view of the baby's most recent growth metrics directly within the Baby Profile.

**Description**
Growth Information surfaces the latest recorded Weight, Height, and Head Circumference (from Growth Records, Section 10.14) as a quick-reference summary within the Baby Profile, linking through to full Growth Charts and History.

**Inputs**
- Most recent Growth Record entries (Section 10.14) for the active baby.

**Outputs**
- A summary display of latest Weight, Height, Head Circumference, and their recorded dates.

**Preconditions**
- At least one Growth Record entry exists.

**Postconditions**
- User has quick access to the baby's latest growth snapshot from within the profile.

**User Actions**
1. User navigates to Baby Profile → Growth Information.
2. User views the latest metrics.
3. User taps through to full Growth Records (Section 10.14) for detail/history.

**System Behaviour**
- The system SHALL display the most recent value for each tracked growth metric, with its recording date.
- The system SHALL link directly to the full Growth Records module for detailed history and charts.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PGI-01 | Displayed values must reflect the most recent Growth Record entry by date for the active baby. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No Growth Records exist yet | Display "No growth data recorded yet" with a prompt to add the first entry. |

**Success Conditions**
- Growth Information accurately reflects the baby's latest recorded metrics at all times.

---

### 10.13.5 Hospital Information

**Purpose**
To present and allow management of the baby's default hospital/clinic of care.

**Description**
Hospital Information stores the baby's primary hospital/clinic, used as the default value pre-filled into Vaccination Management (Section 10.10.7) and available for quick reference (e.g., by a babysitter in an emergency).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Hospital/Clinic Name | Text | No |
| Address | Text | No |
| Phone Number | Text | No |

**Outputs**
- Updated default Hospital Information for the baby profile.

**Preconditions**
- A baby profile exists.

**Postconditions**
- Hospital Information is available as a default across relevant modules and for quick caregiver reference.

**User Actions**
1. User navigates to Baby Profile → Hospital Information.
2. User enters/edits hospital details.
3. User saves.

**System Behaviour**
- The system SHALL store Hospital Information as part of the baby profile.
- The system SHALL make this information available as the default in Vaccination Management (Section 10.10.7).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PHOSP-01 | Phone Number, if provided, must conform to a valid phone number format. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid phone number format | Display inline validation error. |

**Success Conditions**
- Hospital Information is accurately stored and correctly defaults into relevant modules.

---

### 10.13.6 Doctor Information

**Purpose**
To present and allow management of the baby's primary/default doctor.

**Description**
Doctor Information stores the baby's primary pediatrician, used as the default value pre-filled into Vaccination Management (Section 10.10.6) and available for quick caregiver reference.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Doctor Name | Text | No |
| Specialty | Text | No |
| Phone Number | Text | No |
| Email | Text | No |

**Outputs**
- Updated default Doctor Information for the baby profile.

**Preconditions**
- A baby profile exists.

**Postconditions**
- Doctor Information is available as a default across relevant modules and for quick caregiver reference.

**User Actions**
1. User navigates to Baby Profile → Doctor Information.
2. User enters/edits doctor details.
3. User saves.

**System Behaviour**
- The system SHALL store Doctor Information as part of the baby profile.
- The system SHALL make this information available as the default in Vaccination Management (Section 10.10.6).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PDOC-01 | Phone Number and Email, if provided, must conform to valid formats. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid phone/email format | Display inline validation error. |

**Success Conditions**
- Doctor Information is accurately stored and correctly defaults into relevant modules.

---

### 10.13.7 Allergies

**Purpose**
To present a clearly visible, quick-reference view of the baby's known allergies.

**Description**
Allergies surfaces the allergy list captured under Medical Information (Section 10.13.3) with elevated visual prominence within the Baby Profile, given its safety-critical nature for any caregiver (including temporary babysitters).

**Inputs**
- Known Allergies list (from Section 10.13.3 / 10.3.3).

**Outputs**
- A prominently displayed allergy list within the Baby Profile summary.

**Preconditions**
- A baby profile exists.

**Postconditions**
- Any caregiver viewing the profile has immediate visibility of known allergies.

**User Actions**
- User views the Allergies section on the Baby Profile screen.
- User with edit permission may add/remove allergy entries (redirects to Section 10.13.3 editing).

**System Behaviour**
- The system SHALL display known allergies with elevated visual emphasis (e.g., warning color/icon) at the top of the Baby Profile summary when any are present.
- The system SHALL keep this display synchronized with edits made under Medical Information (Section 10.13.3).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PALG-01 | Allergy entries displayed must exactly match the current Known Allergies data in Medical Information. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No known allergies recorded | Omit the elevated allergy banner; optionally display "No known allergies recorded." |

**Success Conditions**
- Known allergies are prominently, accurately, and consistently displayed to all caregivers viewing the profile.

---

### 10.13.8 Emergency Contacts

**Purpose**
To maintain a readily accessible list of emergency contacts for the baby.

**Description**
Emergency Contacts allows the family to store one or more emergency contact entries (name, relationship, phone number), accessible quickly by any caregiver, including babysitters, in urgent situations.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Contact Name | Text | Yes |
| Relationship | Text/Selection | No |
| Phone Number | Text | Yes |

**Outputs**
- A stored list of emergency contacts displayed within the Baby Profile.

**Preconditions**
- A baby profile exists.

**Postconditions**
- Emergency Contacts are available for quick reference by any authorized caregiver.

**User Actions**
1. User navigates to Baby Profile → Emergency Contacts.
2. User adds/edits/removes contact entries.
3. User saves.

**System Behaviour**
- The system SHALL allow multiple Emergency Contact entries per baby profile.
- The system SHALL make Emergency Contacts visible (at minimum, read-only) to all caregivers with access to the baby profile, regardless of role permission level, given their safety-critical nature.
- The system SHOULD support tapping a contact's phone number to initiate a call directly from the device.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PEC-01 | Contact Name and Phone Number must not be empty. |
| VR-PEC-02 | Phone Number must conform to a valid phone number format. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Required field missing | Prevent save and display inline validation error. |
| Invalid phone number format | Display inline validation error. |

**Success Conditions**
- Emergency Contacts are accurately stored and reliably accessible to all caregivers.

---

### 10.13.9 Edit Profile

**Purpose**
To provide a unified entry point for editing all sections of the Baby Profile.

**Description**
Edit Profile is the cross-cutting editing mode/control that allows a permitted user to modify any section of the Baby Profile (Baby Details, Medical Information, Hospital/Doctor Information, Allergies, Emergency Contacts) from a single, coherent editing flow.

**Inputs**
- User edits across any Baby Profile section.

**Outputs**
- Updated Baby Profile record(s) across the edited sections.

**Preconditions**
- A baby profile exists.
- User holds Edit or Full Access role permission (Section 10.20).

**Postconditions**
- All edited sections are updated and reflected consistently throughout the application.

**User Actions**
1. User navigates to Baby Profile.
2. User taps "Edit Profile."
3. User modifies one or more fields across sections.
4. User saves or cancels.

**System Behaviour**
- The system SHALL enter a distinct editing mode, clearly distinguishing editable fields from the default read-only profile view.
- The system SHALL apply the validation rules specific to each edited section (Sections 10.13.1–10.13.8) upon save.
- The system SHALL allow the user to cancel and discard unsaved changes.
- The system SHALL restrict access to Edit Profile based on the user's assigned role permission (Section 10.20).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PEDIT-01 | Only users with Edit or Full Access role permission may enter Edit Profile mode. |
| VR-PEDIT-02 | All section-specific validation rules must be enforced before any changes are saved. |

**Error Handling**

| Scenario | System Response |
|---|---|
| User without permission attempts to access Edit Profile | Deny access and display a permission-denied message. |
| Validation failure in any section during save | Prevent save, highlight the failing section(s), and display specific inline errors. |
| Network unavailable during save | Persist changes locally and queue for synchronization per Offline Mode rules (Section 10.18). |

**Success Conditions**
- All valid edits across Baby Profile sections are reliably saved and consistently reflected throughout the application.

---

## 10.14 Growth Records

### 10.14.1 Weight Tracking

**Purpose**
To allow caregivers to record the baby's weight over time.

**Description**
Weight Tracking captures individual weight measurements with a timestamp, forming a longitudinal record used in Growth Charts (Section 10.14.5) and History (Section 10.14.6).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Weight Value | Numeric | Yes |
| Unit (kg/lb) | Selection | Yes |
| Measurement Date | Date | Yes |

**Outputs**
- A persisted weight measurement record.

**Preconditions**
- A baby profile exists (an initial entry is auto-created from Birth Weight, Section 10.3.2).

**Postconditions**
- The weight entry is reflected in Growth Charts, History, and the Baby Profile's Growth Information summary (Section 10.13.4).

**User Actions**
1. User navigates to Growth Records → Weight.
2. User enters weight value, unit, and date.
3. User saves.

**System Behaviour**
- The system SHALL store each weight entry as a discrete, timestamped record (not overwriting prior entries).
- The system SHALL support unit conversion between kg and lb for display, per Settings preference.
- The system SHALL update Growth Charts and Growth Information immediately upon save.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-WT-01 | Weight Value must be a positive number within a plausible physiological range for the baby's age. |
| VR-WT-02 | Measurement Date must not be a future date and must not precede the baby's Birth Date. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Weight value outside plausible range | Display inline warning and request confirmation before allowing save. |
| Measurement Date invalid | Display inline validation error and prevent save. |

**Success Conditions**
- Weight entries are accurately recorded and reflected in all dependent views.

---

### 10.14.2 Height Tracking

**Purpose**
To allow caregivers to record the baby's height/length over time.

**Description**
Height Tracking captures individual height/length measurements with a timestamp, forming a longitudinal record used in Growth Charts and History.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Height Value | Numeric | Yes |
| Unit (cm/in) | Selection | Yes |
| Measurement Date | Date | Yes |

**Outputs**
- A persisted height measurement record.

**Preconditions**
- A baby profile exists (an initial entry is auto-created from Birth Height/Length, Section 10.3.2).

**Postconditions**
- The height entry is reflected in Growth Charts, History, and Growth Information.

**User Actions**
1. User navigates to Growth Records → Height.
2. User enters height value, unit, and date.
3. User saves.

**System Behaviour**
- The system SHALL store each height entry as a discrete, timestamped record.
- The system SHALL support unit conversion between cm and in for display, per Settings preference.
- The system SHALL update Growth Charts and Growth Information immediately upon save.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-HT-01 | Height Value must be a positive number within a plausible physiological range for the baby's age. |
| VR-HT-02 | Measurement Date must not be a future date and must not precede the baby's Birth Date. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Height value outside plausible range | Display inline warning and request confirmation before allowing save. |
| Measurement Date invalid | Display inline validation error and prevent save. |

**Success Conditions**
- Height entries are accurately recorded and reflected in all dependent views.

---

### 10.14.3 Head Circumference

**Purpose**
To allow caregivers to record the baby's head circumference over time, a standard pediatric growth indicator.

**Description**
Head Circumference captures individual measurements with a timestamp, forming a longitudinal record used in Growth Charts and History, alongside Weight and Height.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Head Circumference Value | Numeric | Yes |
| Unit (cm/in) | Selection | Yes |
| Measurement Date | Date | Yes |

**Outputs**
- A persisted head circumference measurement record.

**Preconditions**
- A baby profile exists.

**Postconditions**
- The entry is reflected in Growth Charts and History.

**User Actions**
1. User navigates to Growth Records → Head Circumference.
2. User enters the measurement value, unit, and date.
3. User saves.

**System Behaviour**
- The system SHALL store each entry as a discrete, timestamped record.
- The system SHALL support unit conversion between cm and in for display.
- The system SHALL update Growth Charts and History immediately upon save.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-HC-01 | Head Circumference Value must be a positive number within a plausible physiological range for the baby's age. |
| VR-HC-02 | Measurement Date must not be a future date and must not precede the baby's Birth Date. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Value outside plausible range | Display inline warning and request confirmation before allowing save. |

**Success Conditions**
- Head Circumference entries are accurately recorded and reflected in all dependent views.

---

### 10.14.4 BMI (Future Support)

**Purpose**
To document Body Mass Index tracking as a planned, not-yet-active capability of the Growth Records module.

**Description**
BMI (Future Support) is explicitly identified as a future-scope calculated metric (derived from Weight and Height), reserved for a subsequent release once age-appropriate infant BMI reference charts are integrated. It is documented here for completeness of scope, consistent with its listing under System Scope, but is not part of the current functional baseline.

**Inputs**
- Not applicable in the current release (future: Weight and Height entries with matching or interpolated dates).

**Outputs**
- Not applicable in the current release (future: a calculated BMI value and percentile).

**Preconditions**
- Not applicable in the current release.

**Postconditions**
- Not applicable in the current release.

**User Actions**
- None in the current release; the application MAY display a "Coming Soon" indicator within Growth Records.

**System Behaviour**
- The system SHALL NOT present BMI values or calculations in the current release.
- The system MAY display a clearly labeled "Coming Soon" placeholder for BMI within the Growth Records module.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BMI-01 | No BMI value may be calculated or displayed until this capability is formally moved into an active release scope. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A (not implemented) | N/A |

**Success Conditions**
- BMI is clearly and accurately represented as a future-scope item, with no misleading partial implementation exposed to users.

---

### 10.14.5 Growth Charts

**Purpose**
To visually present the baby's growth trends over time for Weight, Height, and Head Circumference.

**Description**
Growth Charts render line-graph visualizations of each tracked metric across the baby's recorded history, supporting quick visual trend assessment and, where feasible, comparison against general reference percentile bands.

**Inputs**
- All Weight, Height, and Head Circumference entries for the active baby.

**Outputs**
- Rendered line charts, one per metric, plotting value against age/date.

**Preconditions**
- At least two measurement entries exist for a given metric to render a meaningful trend line (a single point MAY still be plotted).

**Postconditions**
- User can visually assess the baby's growth trend for each tracked metric.

**User Actions**
1. User navigates to Growth Records → Growth Charts.
2. User selects a metric (Weight/Height/Head Circumference) to view.
3. User may toggle reference percentile bands, where available.

**System Behaviour**
- The system SHALL plot all recorded entries for a selected metric in chronological order.
- The system SHOULD overlay general reference percentile bands where reference data is available, clearly labeled as general reference information, not a personalized medical assessment.
- The system SHALL update charts immediately upon addition of a new measurement entry.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GC-01 | Growth Charts must only plot entries belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data to render a trend line | Display available data points with a note that more entries will improve trend visibility. |

**Success Conditions**
- Growth Charts accurately and clearly visualize recorded growth data for each tracked metric.

---

### 10.14.6 Growth History

**Purpose**
To provide a complete, chronological, tabular record of all growth measurements for the active baby.

**Description**
Growth History lists every recorded Weight, Height, and Head Circumference entry in a filterable, chronological table, complementing the visual Growth Charts with precise, reviewable data.

**Inputs**
- All Weight, Height, and Head Circumference entries for the active baby.

**Outputs**
- A chronological, filterable table of growth measurements.

**Preconditions**
- At least one growth measurement entry exists.

**Postconditions**
- All growth measurements remain accessible for review, editing, and deletion.

**User Actions**
1. User navigates to Growth Records → Growth History.
2. User filters by metric type or date range.
3. User taps an entry to view, edit, or delete it.

**System Behaviour**
- The system SHALL display growth entries in reverse-chronological order by default, filterable by metric type.
- The system SHALL allow editing and deletion of existing entries, subject to role permission.
- The system SHALL update Growth Charts and Growth Information immediately upon any create/edit/delete action.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GH-01 | Growth History must only display entries belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- Growth History accurately and completely reflects all recorded growth measurements.

---

### 10.14.7 Export Growth Report

**Purpose**
To allow users to generate a portable, shareable report of the baby's growth history, primarily for pediatric consultations.

**Description**
Export Growth Report compiles Growth History and Growth Charts into a downloadable/shareable document (see Export PDF, Section 10.16.9), suitable for presentation to a pediatrician or for personal record-keeping.

**Inputs**
- User-selected date range and metric(s) to include.

**Outputs**
- A generated report file (PDF), containing tabular data and chart visualizations for the selected scope.

**Preconditions**
- At least one growth measurement entry exists.

**Postconditions**
- User has a portable report file, saved locally and/or shared directly from the device.

**User Actions**
1. User navigates to Growth Records → Export Growth Report.
2. User selects date range and metrics to include.
3. User generates and shares/saves the report.

**System Behaviour**
- The system SHALL compile selected Growth History data and corresponding charts into a single report document, consistent with Export PDF requirements (Section 10.16.9).
- The system SHALL clearly label the report with the baby's name, report generation date, and a disclaimer that the data is caregiver-logged and not a substitute for professional medical assessment.
- The system SHALL allow the user to share the generated report via standard device sharing mechanisms (e.g., email, messaging).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-EGR-01 | Exported report content must be limited to data the requesting user is permitted to view for the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Report generation failure | Display error message and allow retry. |
| No data available for the selected range/metrics | Display "No data available for the selected criteria" and prevent generation of an empty report. |

**Success Conditions**
- A complete, accurate, appropriately disclaimed growth report is generated and successfully shareable/saveable.

---

## 10.15 AI Parenting Assistant

### 10.15.1 AI Chat

**Purpose**
To provide users with a conversational interface for asking parenting-related questions and receiving informational responses.

**Description**
AI Chat is the primary interaction surface for the AI Parenting Assistant, allowing free-text questions and providing contextual, informational (non-diagnostic) answers drawing on the topics defined in Sections 10.15.2–10.15.7.

**Inputs**
- User-entered free-text question or message.

**Outputs**
- An AI-generated, informational text response, displayed within the chat interface.

**Preconditions**
- User is authenticated.
- Network connectivity is available (AI Chat requires backend inference and is not available in full offline mode; see Section 10.18).

**Postconditions**
- The exchange is appended to Conversation History (Section 10.15.8).

**User Actions**
1. User navigates to the AI Assistant module.
2. User types and submits a question.
3. User reads the AI-generated response and may continue the conversation.

**System Behaviour**
- The system SHALL accept free-text input and route it to the AI Parenting Assistant Engine (Section 7.2) for response generation.
- The system SHALL display responses in a clear, conversational chat format.
- The system SHALL apply the AI Safety Disclaimer (Section 10.15.9) contextually where a response touches on health-related topics.
- The system SHALL persist each exchange to Conversation History.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-AICHAT-01 | User input must not exceed a defined maximum message length. |
| VR-AICHAT-02 | Every AI response must be checked against the safety/content policy defined for the assistant (see Section 10.15.9) before display. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Network unavailable | Display "AI Assistant requires an internet connection. Please try again when connected." |
| AI service failure/timeout | Display "Something went wrong. Please try again." and allow retry without losing the user's typed question. |

**Success Conditions**
- User receives a relevant, safe, informational response to their query, and the exchange is reliably recorded in Conversation History.

---

### 10.15.2 Parenting Guidance

**Purpose**
To provide general, informational guidance on common parenting topics beyond the specific categories addressed in Sections 10.15.3–10.15.6.

**Description**
Parenting Guidance covers general newborn care topics (e.g., soothing techniques, babyproofing, routines) through the AI Chat interface, drawing on curated, reviewed informational content.

**Inputs**
- User question related to general parenting topics.

**Outputs**
- An informational response addressing the general parenting query.

**Preconditions**
- AI Chat (Section 10.15.1) is available and operational.

**Postconditions**
- User receives general guidance; exchange recorded in Conversation History.

**User Actions**
- User asks a general parenting question via AI Chat.

**System Behaviour**
- The system SHALL classify and route general parenting queries to appropriate informational response content.
- The system SHALL avoid providing guidance on topics outside its defined scope (e.g., unrelated legal or financial advice), redirecting the user appropriately if such a query is received.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PG-01 | Responses must remain within the defined scope of newborn/infant parenting topics. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Query falls outside defined scope | Respond with a clear statement that the topic is outside the assistant's intended scope. |

**Success Conditions**
- General parenting queries receive relevant, appropriately scoped informational responses.

---

### 10.15.3 Feeding Advice

**Purpose**
To provide informational guidance on feeding-related questions, optionally informed by the user's own logged Feeding data.

**Description**
Feeding Advice addresses questions about feeding frequency, quantity norms, weaning, and related topics, and MAY reference the user's own Feeding History (Section 10.7.9) to provide more contextually relevant (though still non-diagnostic) responses.

**Inputs**
- User question related to feeding.
- (Optionally) the active baby's recent Feeding History, with user consent.

**Outputs**
- An informational response addressing the feeding-related query.

**Preconditions**
- AI Chat is available and operational.

**Postconditions**
- User receives feeding guidance; exchange recorded in Conversation History.

**User Actions**
- User asks a feeding-related question via AI Chat.

**System Behaviour**
- The system SHALL classify and route feeding-related queries to appropriate informational response content.
- The system MAY incorporate summarized statistics from the baby's own Feeding History into the response where relevant and where the user has not disabled this personalization in Settings.
- The system SHALL include the AI Safety Disclaimer where the query relates to potential health concerns (e.g., "baby not feeding enough").

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FA-01 | Any personalized data referenced in a response must belong to the active baby profile only. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient logged data to personalize response | Provide general informational guidance without personalization. |

**Success Conditions**
- Feeding-related queries receive relevant, safe, optionally personalized informational responses.

---

### 10.15.4 Sleeping Advice

**Purpose**
To provide informational guidance on sleep-related questions, optionally informed by the user's own logged Sleep data.

**Description**
Sleeping Advice addresses questions about sleep schedules, sleep training concepts, and typical sleep duration norms by age, and MAY reference the user's own Sleep History (Section 10.8.6) for contextual relevance.

**Inputs**
- User question related to sleep.
- (Optionally) the active baby's recent Sleep History, with user consent.

**Outputs**
- An informational response addressing the sleep-related query.

**Preconditions**
- AI Chat is available and operational.

**Postconditions**
- User receives sleep guidance; exchange recorded in Conversation History.

**User Actions**
- User asks a sleep-related question via AI Chat.

**System Behaviour**
- The system SHALL classify and route sleep-related queries to appropriate informational response content.
- The system MAY incorporate summarized statistics from the baby's own Sleep History into the response, where enabled.
- The system SHALL include the AI Safety Disclaimer where the query relates to potential health/safety concerns (e.g., sleep safety practices).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SLA-01 | Any personalized data referenced in a response must belong to the active baby profile only. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient logged data to personalize response | Provide general informational guidance without personalization. |

**Success Conditions**
- Sleep-related queries receive relevant, safe, optionally personalized informational responses.

---

### 10.15.5 Vaccination Guidance

**Purpose**
To provide informational guidance on vaccination-related questions.

**Description**
Vaccination Guidance addresses general questions about immunization schedules, typical side effects, and preparation for appointments, complementing the structured data in Vaccination Management (Section 10.10) without replacing pediatrician consultation.

**Inputs**
- User question related to vaccinations.

**Outputs**
- An informational response addressing the vaccination-related query.

**Preconditions**
- AI Chat is available and operational.

**Postconditions**
- User receives vaccination guidance; exchange recorded in Conversation History.

**User Actions**
- User asks a vaccination-related question via AI Chat.

**System Behaviour**
- The system SHALL classify and route vaccination-related queries to appropriate informational response content.
- The system SHALL explicitly avoid providing individualized medical recommendations about specific vaccine timing changes, deferring such decisions to the user's pediatrician.
- The system SHALL include the AI Safety Disclaimer on all vaccination-related responses.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VG-01 | Responses must not recommend altering, skipping, or delaying a specific scheduled vaccination. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Query requests individualized medical advice (e.g., "should I skip this vaccine") | Respond with general informational content and a clear recommendation to discuss with the baby's pediatrician. |

**Success Conditions**
- Vaccination-related queries receive relevant, safe, appropriately bounded informational responses.

---

### 10.15.6 Growth Guidance

**Purpose**
To provide informational guidance on growth-related questions, optionally informed by the user's own logged Growth data.

**Description**
Growth Guidance addresses questions about typical growth patterns and interpretation of growth trends, and MAY reference the user's own Growth Records (Section 10.14) for contextual relevance.

**Inputs**
- User question related to growth.
- (Optionally) the active baby's recent Growth Records, with user consent.

**Outputs**
- An informational response addressing the growth-related query.

**Preconditions**
- AI Chat is available and operational.

**Postconditions**
- User receives growth guidance; exchange recorded in Conversation History.

**User Actions**
- User asks a growth-related question via AI Chat.

**System Behaviour**
- The system SHALL classify and route growth-related queries to appropriate informational response content.
- The system MAY incorporate summarized statistics from the baby's own Growth Records into the response, where enabled.
- The system SHALL explicitly avoid presenting any percentile or trend commentary as a medical diagnosis, including the AI Safety Disclaimer on relevant responses.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GG-01 | Any personalized data referenced in a response must belong to the active baby profile only. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient logged data to personalize response | Provide general informational guidance without personalization. |

**Success Conditions**
- Growth-related queries receive relevant, safe, optionally personalized informational responses.

---

### 10.15.7 Health Education

**Purpose**
To provide general informational, educational content on common newborn health topics.

**Description**
Health Education addresses general educational queries (e.g., "what is jaundice," "common newborn skin conditions") with informational content, explicitly distinguished from diagnosis or treatment advice for the user's specific baby.

**Inputs**
- User question related to general newborn health topics.

**Outputs**
- An informational, educational response.

**Preconditions**
- AI Chat is available and operational.

**Postconditions**
- User receives educational content; exchange recorded in Conversation History.

**User Actions**
- User asks a health-education-related question via AI Chat.

**System Behaviour**
- The system SHALL classify and route health-education queries to appropriate informational content.
- The system SHALL always include the AI Safety Disclaimer (Section 10.15.9) on health-education responses.
- The system SHALL never generate a response that diagnoses a condition in the user's specific baby, even if symptoms are described; it SHALL instead recommend consulting a pediatrician, especially for any query suggesting a potential emergency.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-HE-01 | No response may state or strongly imply a diagnosis for the user's specific baby. |
| VR-HE-02 | Any query describing potential emergency symptoms (e.g., difficulty breathing, high fever in a young infant) must trigger an urgent "seek immediate medical attention" response. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Query describes potential emergency symptoms | Immediately display an urgent, clearly formatted recommendation to seek emergency medical care or contact emergency services, in addition to any general informational content. |

**Success Conditions**
- Health education queries receive safe, appropriately disclaimed, non-diagnostic informational responses, with emergency-indicative queries reliably triggering urgent care guidance.

---

### 10.15.8 Conversation History

**Purpose**
To maintain a persistent record of past AI Assistant conversations for user reference.

**Description**
Conversation History stores the full sequence of user questions and AI responses across sessions, organized chronologically and (optionally) by topic/session, allowing users to revisit prior guidance.

**Inputs**
- All AI Chat exchanges (Sections 10.15.1–10.15.7) for the authenticated user.

**Outputs**
- A chronological, reviewable list of past conversations.

**Preconditions**
- At least one AI Chat exchange has occurred.

**Postconditions**
- Past conversations remain accessible for review until deleted by the user.

**User Actions**
1. User navigates to AI Assistant → Conversation History.
2. User browses or searches past conversations.
3. User may delete individual conversations.

**System Behaviour**
- The system SHALL persist all AI Chat exchanges, scoped to the authenticated user (and, where relevant, the active baby profile context at the time of the exchange).
- The system SHALL allow users to delete individual past conversations.
- The system SHALL synchronize Conversation History to the cloud when connectivity is available, consistent with Section 10.18.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ACH-01 | Conversation History must only be visible to the user who conducted the conversation, unless explicitly shared. |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- All AI Assistant conversations are reliably recorded and remain accessible for later review.

---

### 10.15.9 AI Safety Disclaimer

**Purpose**
To ensure users consistently understand the informational, non-diagnostic nature of AI Assistant (and AI Cry Analyzer) content, and are directed to professional medical care where appropriate.

**Description**
The AI Safety Disclaimer is a cross-cutting requirement governing all AI-generated content within the application (AI Chat responses and Cry Analyzer recommendations), ensuring consistent, prominent framing that distinguishes informational guidance from medical diagnosis or treatment.

**Inputs**
- Any AI-generated response classified as health-, growth-, feeding-, sleep-, or vaccination-adjacent.

**Outputs**
- A consistently displayed disclaimer statement accompanying relevant AI-generated content.

**Preconditions**
- An AI-generated response has been produced by AI Chat or the Cry Analyzer.

**Postconditions**
- User is consistently and clearly informed of the non-diagnostic nature of the content and, where relevant, prompted to seek professional care.

**User Actions**
- User reads the disclaimer as part of the AI-generated content.

**System Behaviour**
- The system SHALL display a disclaimer on all AI Assistant responses addressing health-adjacent topics (Sections 10.15.3–10.15.7) and on all Cry Analyzer Recommendations (Section 10.6.11).
- The system SHALL never allow AI-generated content to state or strongly imply a medical diagnosis for the user's specific baby.
- The system SHALL escalate to explicit "seek immediate medical attention" language when user input indicates potential emergency symptoms (consistent with VR-HE-02).
- The system SHALL make the disclaimer visually distinct but non-intrusive (e.g., a persistent footer note), consistent with accessibility-first, low-text-complexity design principles.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-AISAFE-01 | Every health-adjacent AI response must include the disclaimer before being presented as complete to the user. |
| VR-AISAFE-02 | No AI-generated content may be released without passing this disclaimer/safety check. |

**Error Handling**

| Scenario | System Response |
|---|---|
| AI-generated content fails the safety/disclaimer check | Suppress the non-compliant response and display a safe fallback message directing the user to consult a pediatrician. |

**Success Conditions**
- All relevant AI-generated content is consistently and reliably accompanied by an appropriate safety disclaimer, with no instance of implied diagnosis reaching the user.

---

## 10.16 Reports and Analytics

### 10.16.1 Daily Reports

**Purpose**
To provide a consolidated, single-day summary report spanning all tracking modules for the active baby.

**Description**
Daily Reports aggregate the current (or a selected past) day's activity across Feeding, Sleep, Diaper, Cry Analyzer, and any other logged modules into one consolidated report view, extending beyond the Dashboard's Daily Summary (Section 10.5.2) with fuller detail.

**Inputs**
- All tracking records timestamped within the selected calendar day for the active baby.

**Outputs**
- A consolidated Daily Report view/document summarizing all module activity for the selected day.

**Preconditions**
- At least one tracking record exists for the selected day.

**Postconditions**
- User has a complete, single-day overview of the baby's care activity.

**User Actions**
1. User navigates to Reports and Analytics → Daily Reports.
2. User selects a date (defaulting to today).
3. User reviews the consolidated report and may export it (Sections 10.16.10–10.16.11).

**System Behaviour**
- The system SHALL aggregate data from all applicable tracking modules for the selected calendar day.
- The system SHALL default to the current day and allow navigation to any past date with available data.
- The system SHALL clearly section the report by module (Feeding, Sleep, Diaper, Cry Analyzer, etc.).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DREP-01 | Daily Reports must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No data exists for the selected day | Display "No activity recorded for this day." |

**Success Conditions**
- Daily Reports accurately and completely consolidate all tracked activity for the selected day.

---

### 10.16.2 Weekly Reports

**Purpose**
To provide a consolidated, seven-day summary report spanning all tracking modules for the active baby.

**Description**
Weekly Reports aggregate a selected seven-day period's activity across all tracking modules, presenting totals, averages, and trend indicators suitable for a broader view than daily reporting.

**Inputs**
- All tracking records timestamped within the selected seven-day window for the active baby.

**Outputs**
- A consolidated Weekly Report view/document.

**Preconditions**
- At least one tracking record exists within the selected week.

**Postconditions**
- User has a complete, weekly overview of the baby's care activity and trends.

**User Actions**
1. User navigates to Reports and Analytics → Weekly Reports.
2. User selects a week (defaulting to the current rolling seven-day window).
3. User reviews the consolidated report and may export it.

**System Behaviour**
- The system SHALL aggregate data from all applicable tracking modules for the selected seven-day window.
- The system SHALL present both totals and day-by-day breakdowns within the report.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-WREP-01 | Weekly Reports must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No data exists for the selected week | Display "No activity recorded for this week." |

**Success Conditions**
- Weekly Reports accurately and completely consolidate all tracked activity for the selected week.

---

### 10.16.3 Monthly Reports

**Purpose**
To provide a consolidated, calendar-month summary report spanning all tracking modules for the active baby.

**Description**
Monthly Reports aggregate a selected calendar month's activity across all tracking modules, supporting longer-term review and suitable for pediatric visit preparation.

**Inputs**
- All tracking records timestamped within the selected calendar month for the active baby.

**Outputs**
- A consolidated Monthly Report view/document.

**Preconditions**
- At least one tracking record exists within the selected month.

**Postconditions**
- User has a complete, monthly overview of the baby's care activity and trends.

**User Actions**
1. User navigates to Reports and Analytics → Monthly Reports.
2. User selects a month (defaulting to the current month).
3. User reviews the consolidated report and may export it.

**System Behaviour**
- The system SHALL aggregate data from all applicable tracking modules for the selected calendar month.
- The system SHALL present totals, week-by-week breakdowns, and available trend indicators within the report.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MREP-01 | Monthly Reports must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No data exists for the selected month | Display "No activity recorded for this month." |

**Success Conditions**
- Monthly Reports accurately and completely consolidate all tracked activity for the selected month.

---

### 10.16.4 Feeding Analytics

**Purpose**
To provide deeper analytical insight into feeding patterns beyond the basic statistics available within the Feeding Tracker.

**Description**
Feeding Analytics presents trend analysis across feeding type distribution, intake volume trends, and breastfeeding side-alternation patterns, drawing on the full Feeding History (Section 10.7.9) over a user-selected period.

**Inputs**
- All Feeding History records within the selected period for the active baby.

**Outputs**
- Analytical visualizations and summary insights specific to feeding patterns.

**Preconditions**
- Sufficient Feeding History exists to produce meaningful analysis.

**Postconditions**
- User gains deeper insight into feeding trends over time.

**User Actions**
1. User navigates to Reports and Analytics → Feeding Analytics.
2. User selects the analysis period.
3. User reviews the presented insights and visualizations.

**System Behaviour**
- The system SHALL compute feeding type distribution (breastfeeding vs. bottle vs. formula vs. solid) over the selected period.
- The system SHALL compute intake volume trends and breastfeeding side-alternation adherence.
- The system SHALL reuse the same underlying aggregation logic as Section 10.7 Daily/Weekly/Monthly Statistics to ensure consistency.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FANA-01 | Feeding Analytics must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for meaningful analysis | Display "Not enough data yet" state. |

**Success Conditions**
- Feeding Analytics accurately reflects feeding trends over the selected period.

---

### 10.16.5 Sleep Analytics

**Purpose**
To provide deeper analytical insight into sleep patterns beyond the basic statistics available within the Sleep Tracker.

**Description**
Sleep Analytics presents trend analysis across day/night sleep balance, sleep consistency, and quality distribution, drawing on the full Sleep History (Section 10.8.6) over a user-selected period.

**Inputs**
- All Sleep History records within the selected period for the active baby.

**Outputs**
- Analytical visualizations and summary insights specific to sleep patterns.

**Preconditions**
- Sufficient Sleep History exists to produce meaningful analysis.

**Postconditions**
- User gains deeper insight into sleep trends over time.

**User Actions**
1. User navigates to Reports and Analytics → Sleep Analytics.
2. User selects the analysis period.
3. User reviews the presented insights and visualizations.

**System Behaviour**
- The system SHALL compute day/night sleep balance and total sleep trends over the selected period.
- The system SHALL compute Sleep Quality distribution where Quality data has been logged.
- The system SHALL reuse the same underlying aggregation logic as Section 10.8 Daily/Weekly/Monthly Sleep Statistics.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SANA-01 | Sleep Analytics must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for meaningful analysis | Display "Not enough data yet" state. |

**Success Conditions**
- Sleep Analytics accurately reflects sleep trends over the selected period.

---

### 10.16.6 Cry Analytics

**Purpose**
To provide deeper analytical insight into cry analysis patterns over time.

**Description**
Cry Analytics presents trend analysis of cry category frequency (e.g., how often "Hungry" versus "Tired" predictions occur), time-of-day distribution, and prediction confidence trends, drawing on Prediction History (Section 10.6.12) over a user-selected period.

**Inputs**
- All Prediction History records within the selected period for the active baby.

**Outputs**
- Analytical visualizations and summary insights specific to cry analysis trends.

**Preconditions**
- Sufficient Prediction History exists to produce meaningful analysis.

**Postconditions**
- User gains deeper insight into cry pattern trends over time.

**User Actions**
1. User navigates to Reports and Analytics → Cry Analytics.
2. User selects the analysis period.
3. User reviews the presented insights and visualizations.

**System Behaviour**
- The system SHALL compute frequency distribution across cry categories for the selected period, excluding Non-Cry entries (Section 10.6.5) from cry-category distribution while still reporting their count separately.
- The system SHALL compute time-of-day distribution of cry events.
- The system SHALL present this analysis with the same non-diagnostic framing established for Cry Analyzer results (Section 10.6.11).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CANA-01 | Cry Analytics must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for meaningful analysis | Display "Not enough data yet" state. |

**Success Conditions**
- Cry Analytics accurately reflects cry analysis trends over the selected period.

---

### 10.16.7 Growth Analytics

**Purpose**
To provide deeper analytical insight into growth trends beyond the raw Growth Charts.

**Description**
Growth Analytics presents rate-of-change analysis (e.g., weight gain per week) and, where reference data is available, general percentile-trend framing, drawing on Growth History (Section 10.14.6) over a user-selected period.

**Inputs**
- All Growth History records within the selected period for the active baby.

**Outputs**
- Analytical visualizations and summary insights specific to growth trends.

**Preconditions**
- Sufficient Growth History exists to produce meaningful analysis.

**Postconditions**
- User gains deeper insight into growth trends over time.

**User Actions**
1. User navigates to Reports and Analytics → Growth Analytics.
2. User selects the analysis period and metric.
3. User reviews the presented insights and visualizations.

**System Behaviour**
- The system SHALL compute rate-of-change statistics (e.g., weight gain per week/month) for the selected period.
- The system SHALL present percentile-trend framing as general reference information only, consistent with Section 10.14.5 and the AI Safety Disclaimer principles (Section 10.15.9).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GRANA-01 | Growth Analytics must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for meaningful analysis | Display "Not enough data yet" state. |

**Success Conditions**
- Growth Analytics accurately reflects growth trends over the selected period.

---

### 10.16.8 Vaccination Analytics

**Purpose**
To provide deeper analytical insight into vaccination compliance and timeliness.

**Description**
Vaccination Analytics presents on-time completion rate, average delay for completed vaccinations, and outstanding (Pending/Missed) counts, drawing on Vaccination History (Section 10.10.10) and Progress Tracking (Section 10.10.11).

**Inputs**
- All Vaccination Schedule and History data for the active baby.

**Outputs**
- Analytical visualizations and summary insights specific to vaccination compliance.

**Preconditions**
- A Vaccination Schedule exists with at least one status transition.

**Postconditions**
- User gains deeper insight into vaccination compliance trends.

**User Actions**
1. User navigates to Reports and Analytics → Vaccination Analytics.
2. User reviews the presented insights.

**System Behaviour**
- The system SHALL compute on-time completion rate as the proportion of Completed entries whose Administration Date was on or before the original Due Date.
- The system SHALL compute average delay (in days) for Completed entries administered after their Due Date.
- The system SHALL reuse Progress Tracking figures (Section 10.10.11) for consistency.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VANA-01 | Vaccination Analytics must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for meaningful analysis | Display "Not enough data yet" state. |

**Success Conditions**
- Vaccination Analytics accurately reflects the baby's immunization compliance trends.

---

### 10.16.9 Diaper Analytics

**Purpose**
To provide deeper analytical insight into diaper change patterns over time.

**Description**
Diaper Analytics presents frequency trends and type distribution (Pee/Poop/Mixed/Dry) drawing on Diaper History (Section 10.9.8) over a user-selected period, useful for identifying notable changes (e.g., reduced wet-diaper frequency).

**Inputs**
- All Diaper History records within the selected period for the active baby.

**Outputs**
- Analytical visualizations and summary insights specific to diaper change trends.

**Preconditions**
- Sufficient Diaper History exists to produce meaningful analysis.

**Postconditions**
- User gains deeper insight into diaper change trends over time.

**User Actions**
1. User navigates to Reports and Analytics → Diaper Analytics.
2. User selects the analysis period.
3. User reviews the presented insights and visualizations.

**System Behaviour**
- The system SHALL compute frequency and type-distribution trends over the selected period, applying the same combined-counting rule for Mixed entries as Section 10.9.3.
- The system SHOULD flag a notable downward trend in Pee frequency with a gentle, non-diagnostic informational note recommending caregiver attention, consistent with AI Safety Disclaimer principles.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DIANA-01 | Diaper Analytics must only include data belonging to the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient data for meaningful analysis | Display "Not enough data yet" state. |

**Success Conditions**
- Diaper Analytics accurately reflects diaper change trends over the selected period.

---

### 10.16.10 Export PDF

**Purpose**
To allow users to export any report or analytics view as a portable PDF document.

**Description**
Export PDF compiles the currently viewed report (Daily/Weekly/Monthly Report or any Analytics view) into a formatted PDF document suitable for saving, printing, or sharing with a pediatrician.

**Inputs**
- User-selected report/analytics view and export action.

**Outputs**
- A generated PDF file.

**Preconditions**
- A report or analytics view with data is currently displayed.

**Postconditions**
- User has a saved/shareable PDF file reflecting the exported view.

**User Actions**
1. User views a report/analytics screen.
2. User taps "Export as PDF."
3. User saves or shares the generated file via standard device sharing.

**System Behaviour**
- The system SHALL render the currently viewed report/analytics content, including charts, into a formatted PDF document.
- The system SHALL include the baby's name, export date, and the report's date range/period in the PDF header.
- The system SHALL include the general data-provenance disclaimer (caregiver-logged data, not a medical record) in the PDF footer, consistent with Section 10.14.7.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-EPDF-01 | Exported PDF content must be limited to data the requesting user is permitted to view for the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| PDF generation failure | Display error message and allow retry. |
| No data available in the current view | Prevent export and display "No data available to export." |

**Success Conditions**
- A complete, accurate PDF export is reliably generated and shareable/saveable.

---

### 10.16.11 Export CSV

**Purpose**
To allow users to export raw underlying data from any report or tracking module as a CSV file for external analysis or record-keeping.

**Description**
Export CSV compiles the raw tabular records underlying a selected report or module (e.g., all Feeding History rows within a date range) into a CSV file, distinct from the formatted, visual PDF export.

**Inputs**
- User-selected module/report scope, date range, and export action.

**Outputs**
- A generated CSV file containing raw tabular data.

**Preconditions**
- Data exists within the selected scope and date range.

**Postconditions**
- User has a saved/shareable CSV file reflecting the exported data.

**User Actions**
1. User navigates to the export option within a report or module.
2. User selects the scope and date range.
3. User taps "Export as CSV" and saves/shares the generated file.

**System Behaviour**
- The system SHALL export raw record-level data (not aggregated summaries) into standard CSV format, with clear column headers.
- The system SHALL scope the export strictly to the active baby profile and the selected date range.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ECSV-01 | Exported CSV content must be limited to data the requesting user is permitted to view for the active baby profile. |

**Error Handling**

| Scenario | System Response |
|---|---|
| CSV generation failure | Display error message and allow retry. |
| No data available in the selected scope | Prevent export and display "No data available to export." |

**Success Conditions**
- A complete, accurate CSV export is reliably generated and shareable/saveable.

---

### 10.16.12 Data Visualization

**Purpose**
To establish consistent, accessible visual presentation standards for all analytical data displayed across Reports and Analytics.

**Description**
Data Visualization is a cross-cutting requirement defining how charts, graphs, and summary indicators are rendered consistently across Daily/Weekly/Monthly Reports and all Analytics sub-modules (Sections 10.16.4–10.16.9), with accessibility (color, legibility) as a first-class concern.

**Inputs**
- Aggregated data from any Reports/Analytics sub-module.

**Outputs**
- Consistently styled visual chart/graph components.

**Preconditions**
- Any Reports or Analytics view is being rendered.

**Postconditions**
- All visualizations across the application follow a consistent, accessible visual language.

**User Actions**
- User views charts/graphs as part of any Reports or Analytics screen.

**System Behaviour**
- The system SHALL apply a consistent color, typography, and layout system across all data visualizations in the application.
- The system SHALL ensure color usage in visualizations is not the sole means of conveying information (e.g., pairing color with labels/patterns), consistent with Accessibility Requirements addressed later in this document.
- The system SHALL ensure all visualizations remain legible and correctly rendered across supported device sizes.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DVIZ-01 | No chart may rely solely on color to distinguish data series without an accompanying label or pattern differentiation. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Chart rendering failure | Fall back to a plain tabular/numeric display of the underlying data. |

**Success Conditions**
- Data visualizations are consistently, accessibly, and correctly rendered across all Reports and Analytics views.

---

### 10.16.13 Charts and Graphs

**Purpose**
To define the specific chart/graph types used to present each category of analytical data.

**Description**
Charts and Graphs specifies the mapping of chart type to data category (e.g., line charts for Growth trends, bar charts for feeding-type distribution, pie/donut charts for cry-category distribution), ensuring each analytical view uses a chart type appropriate to its data shape.

**Inputs**
- Aggregated data from any Reports/Analytics sub-module.

**Outputs**
- The appropriately typed chart/graph rendered for each analytical view.

**Preconditions**
- Any Reports or Analytics view is being rendered.

**Postconditions**
- Each analytical view presents its data using a chart type appropriate to that data's nature.

**User Actions**
- User views and, where supported, interacts with charts (e.g., tapping a data point for detail).

**System Behaviour**
- The system SHALL use line charts for time-series trend data (e.g., Growth Charts, Weekly/Monthly Sleep trends).
- The system SHALL use bar charts for categorical comparison data (e.g., feeding type distribution, diaper type counts).
- The system SHALL use pie/donut or probability-bar visualizations for proportional distribution data (e.g., Cry Analyzer Probability Distribution, Section 10.6.10).
- The system SHALL support tapping/selecting a data point to reveal its precise underlying value.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CG-01 | Chart type selection must remain consistent for a given data category across all screens where it appears. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Data shape does not fit any defined chart type | Fall back to a plain tabular display. |

**Success Conditions**
- Every analytical data category is consistently presented using an appropriately typed, interactive chart or graph.

---

## 10.17 Notification System

### 10.17.1 Feeding Reminder

**Purpose**
To remind caregivers when it is approximately time for the baby's next feeding, based on recent feeding patterns.

**Description**
Feeding Reminder generates a notification a configurable interval after the last logged feeding session, helping caregivers maintain a consistent feeding routine.

**Inputs**
- Timestamp of the most recent Feeding entry (Section 10.7) for the active baby.
- User-configured reminder interval (Settings, Section 10.21.4).

**Outputs**
- A push and/or local notification prompting the user to consider the next feeding.

**Preconditions**
- Feeding Reminders are enabled in Notification Preferences.
- At least one feeding session has been logged.

**Postconditions**
- User is alerted at the appropriate interval following the last feeding.

**User Actions**
- User receives and may tap the notification to navigate directly to Feeding Tracker.

**System Behaviour**
- The system SHALL schedule a Feeding Reminder relative to the timestamp of the most recently logged feeding session.
- The system SHALL reschedule the reminder automatically whenever a new feeding session is logged.
- The system SHALL respect the user's enabled/disabled and interval preferences from Notification Preferences (Section 10.17.10).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FREM-01 | A Feeding Reminder must not be scheduled if the feature is disabled in Notification Preferences. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No feeding session logged yet | Do not schedule a reminder until an initial feeding is logged. |

**Success Conditions**
- Feeding Reminders are reliably delivered at the configured interval, correctly rescheduling as new feedings are logged.

---

### 10.17.2 Sleeping Reminder

**Purpose**
To remind caregivers of an approaching typical nap/sleep time, based on recent sleep patterns.

**Description**
Sleeping Reminder generates a notification based on the baby's recent Sleep History (Section 10.8.6) patterns, helping caregivers anticipate and prepare for the baby's next sleep window.

**Inputs**
- Recent Sleep History patterns for the active baby.
- User-configured reminder preferences.

**Outputs**
- A push and/or local notification prompting the user to prepare for the baby's next sleep.

**Preconditions**
- Sleeping Reminders are enabled in Notification Preferences.
- Sufficient Sleep History exists to estimate a pattern.

**Postconditions**
- User is alerted ahead of an anticipated sleep window.

**User Actions**
- User receives and may tap the notification to navigate directly to Sleep Tracker.

**System Behaviour**
- The system SHALL estimate an approximate next-sleep window based on recent Sleep History patterns where sufficient data exists.
- The system SHALL respect the user's enabled/disabled preferences from Notification Preferences.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SREM-01 | A Sleeping Reminder must not be scheduled if the feature is disabled in Notification Preferences. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Insufficient Sleep History to estimate a pattern | Do not schedule pattern-based reminders until sufficient data exists. |

**Success Conditions**
- Sleeping Reminders are reliably delivered when a sufficient pattern can be estimated and the feature is enabled.

---

### 10.17.3 Vaccination Reminder

**Purpose**
To remind caregivers of upcoming, appointment-linked, and missed vaccinations.

**Description**
Vaccination Reminder is the notification delivery mechanism for the Reminder Notifications requirements already defined under Vaccination Management (Section 10.10.9), delivered through the shared Notification System infrastructure.

**Inputs**
- Vaccination Schedule Due Dates, Appointment times, and Missed status transitions (Section 10.10).

**Outputs**
- Push and/or local notifications at configured intervals.

**Preconditions**
- Vaccination Reminders are enabled in Notification Preferences.
- A relevant vaccination schedule entry or appointment exists.

**Postconditions**
- User is alerted per the schedule defined in Section 10.10.9.

**User Actions**
- User receives and may tap the notification to navigate directly to the relevant vaccination entry.

**System Behaviour**
- The system SHALL deliver Vaccination Reminders as specified in Section 10.10.9, subject to the user's Notification Preferences.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VXREM-01 | A Vaccination Reminder must not be scheduled if the feature is disabled in Notification Preferences. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Notification permission not granted | Fall back to in-app banner alerts, consistent with Section 10.10.9 Error Handling. |

**Success Conditions**
- Vaccination Reminders are reliably delivered consistent with Section 10.10.9, subject to user preference.

---

### 10.17.4 Medication Reminder

**Purpose**
To remind caregivers when a scheduled medication dose is due for the baby.

**Description**
Medication Reminder allows caregivers to define a medication schedule (name, dosage, frequency) and receive timely reminders for each dose, supporting adherence to prescribed treatments.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Medication Name | Text | Yes |
| Dosage | Text | No |
| Frequency/Schedule | Selection/Custom | Yes |
| Start Date | Date | Yes |
| End Date | Date | No |

**Outputs**
- Scheduled push and/or local notifications for each due dose.

**Preconditions**
- Medication Reminders are enabled in Notification Preferences.
- User has entered a medication schedule.

**Postconditions**
- User is alerted at each scheduled dose time until the medication schedule ends or is removed.

**User Actions**
1. User navigates to Notification Preferences (or Medical Information) → Medication Reminders.
2. User adds a medication with dosage and frequency.
3. User receives reminders and may mark a dose as given.

**System Behaviour**
- The system SHALL generate recurring reminders according to the defined frequency, from Start Date until End Date (or until manually removed).
- The system SHALL allow the user to mark individual doses as given, and SHOULD log this in a lightweight medication log for reference.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MEDREM-01 | Medication Name and Frequency must not be empty. |
| VR-MEDREM-02 | End Date, if provided, must not be earlier than Start Date. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Required field missing | Prevent save and display inline validation error. |
| End Date before Start Date | Display validation error and prevent save. |

**Success Conditions**
- Medication Reminders are reliably delivered according to the defined schedule until completion or removal.

---

### 10.17.5 Milestone Reminder

**Purpose**
To proactively notify caregivers when the baby is approaching or within the expected age range for an upcoming, not-yet-achieved milestone.

**Description**
Milestone Reminder generates a notification when the baby's current age enters the Expected Age range (Section 10.11.2) of a not-yet-achieved standard milestone, encouraging caregiver observation and engagement.

**Inputs**
- Baby's current age (derived from Birth Date).
- Standard milestone Expected Age ranges and current Achievement status (Section 10.11).

**Outputs**
- A push and/or local notification referencing the relevant upcoming milestone.

**Preconditions**
- Milestone Reminders are enabled in Notification Preferences.
- At least one standard milestone is not yet marked Achieved and the baby's age has entered its Expected Age range.

**Postconditions**
- User is alerted to watch for and log the relevant milestone.

**User Actions**
- User receives and may tap the notification to navigate directly to Milestone Tracking.

**System Behaviour**
- The system SHALL evaluate the baby's current age against not-yet-achieved milestone Expected Age ranges on a regular basis (e.g., daily).
- The system SHALL generate a reminder using neutral, non-alarming language consistent with Section 10.11.2.
- The system SHALL avoid duplicate reminders for the same milestone within a short repeat window.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MSREM-01 | A Milestone Reminder must not be generated for a milestone already marked Achieved. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- Milestone Reminders are reliably and appropriately delivered as the baby enters relevant developmental age ranges.

---

### 10.17.6 Daily Encouragement

**Purpose**
To provide caregivers with brief, positive, supportive messaging, particularly valuable given the emotional and physical demands of newborn care.

**Description**
Daily Encouragement delivers a short, rotating supportive/motivational message once per day, drawn from a maintained content set, aimed at reducing parental stress consistent with the Project Objectives (Section 2.3).

**Inputs**
- Maintained Daily Encouragement content set.
- User's configured notification time preference.

**Outputs**
- A single daily push and/or local notification containing a supportive message.

**Preconditions**
- Daily Encouragement is enabled in Notification Preferences.

**Postconditions**
- User receives one supportive message per day at their configured time.

**User Actions**
- User receives the notification; no further action required, though the user may tap to view a slightly expanded message within the app.

**System Behaviour**
- The system SHALL deliver exactly one Daily Encouragement notification per day when enabled, at the user's configured time (defaulting to a sensible default, e.g., morning).
- The system SHALL rotate content to avoid immediate repetition of the same message.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DENC-01 | No more than one Daily Encouragement notification may be sent per calendar day. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- Daily Encouragement messages are reliably delivered once per day, with rotating, non-repetitive content, when enabled.

---

### 10.17.7 Push Notifications

**Purpose**
To deliver time-sensitive alerts to the user's device even when the application is not actively open, via a cloud push notification service.

**Description**
Push Notifications is the delivery mechanism used for all remote-triggered or cloud-synchronized alerts (e.g., a family-sharing invitation from another device, or a reminder generated server-side), requiring an internet connection and device registration with the push service.

**Inputs**
- Notification-triggering events requiring cross-device or server-side delivery.
- Device push token registration.

**Outputs**
- A delivered push notification, visible in the device's system notification tray.

**Preconditions**
- User has granted notification permission.
- Device has (at some point) had connectivity to register with the push service.

**Postconditions**
- The notification is delivered to the device's system notification tray, or queued for delivery when the device reconnects.

**User Actions**
- User receives the notification in their device's notification tray and may tap to open the relevant screen in the application.

**System Behaviour**
- The system SHALL register the device with the push notification service upon successful login (Section 10.1.2), obtaining and storing a device push token.
- The system SHALL route all applicable notification types (Sections 10.17.1–10.17.6) through the push service when the app is backgrounded or closed.
- The system SHALL deep-link the notification tap action to the relevant in-app screen.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PUSH-01 | Push Notifications must only be sent to devices with a valid, current push token for an authenticated user. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Notification permission denied | Fall back to Local Notifications (Section 10.17.8) where feasible, and in-app banners when the app is opened. |
| Push token invalid/expired | Re-register the device token on next successful app launch/login. |

**Success Conditions**
- Push Notifications are reliably delivered to registered, permitted devices for all applicable notification types.

---

### 10.17.8 Local Notifications

**Purpose**
To deliver time-sensitive alerts scheduled and triggered entirely on-device, without requiring an internet connection at delivery time.

**Description**
Local Notifications is the delivery mechanism used for reminders that can be fully scheduled in advance on-device (e.g., a Feeding Reminder timer, a previously scheduled Vaccination appointment reminder), ensuring delivery even when the device is offline at the scheduled time.

**Inputs**
- Notification-triggering events schedulable entirely from locally available data.

**Outputs**
- A delivered local notification, visible in the device's system notification tray, without requiring connectivity at delivery time.

**Preconditions**
- User has granted notification permission.

**Postconditions**
- The notification is reliably delivered at the scheduled local time, regardless of connectivity.

**User Actions**
- User receives the notification and may tap to open the relevant screen in the application.

**System Behaviour**
- The system SHALL use device-local scheduling (not dependent on server push) for all reminder types that can be determined entirely from locally available data (e.g., Feeding Reminder, Medication Reminder, previously scheduled Vaccination appointment reminders).
- The system SHALL ensure Local Notifications function correctly in full Offline Mode (Section 10.18).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-LOCNOT-01 | Local Notifications must not depend on an active network connection at the scheduled delivery time. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Notification permission denied | Display accessible explanation and link to device settings; fall back to in-app banners on next app open. |

**Success Conditions**
- Local Notifications are reliably delivered at their scheduled time regardless of connectivity, for all applicable notification types.

---

### 10.17.9 Notification History

**Purpose**
To maintain a reviewable record of past notifications delivered to the user within the application.

**Description**
Notification History presents an in-app, chronological log of past notifications (reminders, alerts, sync status, family-sharing events), allowing users to review notifications they may have missed or dismissed from the system tray.

**Inputs**
- All notification-triggering events for the authenticated user, across all notification types.

**Outputs**
- A chronological, in-app list of past notifications.

**Preconditions**
- At least one notification has been generated for the user.

**Postconditions**
- Past notifications remain accessible for review within the application.

**User Actions**
1. User navigates to Notification History (e.g., via a bell icon).
2. User reviews past notifications.
3. User taps a notification entry to navigate to the relevant screen.

**System Behaviour**
- The system SHALL log every generated notification (push or local) to an in-app Notification History, regardless of whether the user interacted with the system-level notification.
- The system SHALL display notifications in reverse-chronological order, with unread/read status indicated.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-NHIST-01 | Notification History must only display notifications relevant to the authenticated user and their accessible baby profile(s). |

**Error Handling**

| Scenario | System Response |
|---|---|
| History fails to load | Display non-blocking error with retry option. |

**Success Conditions**
- Notification History accurately and completely reflects all notifications generated for the user.

---

### 10.17.10 Notification Preferences

**Purpose**
To allow users to control which notification types they receive and how.

**Description**
Notification Preferences, accessible via Settings (Section 10.21.4), allows per-type enable/disable toggles and, where applicable, timing/interval configuration for each notification category defined in Sections 10.17.1–10.17.6.

**Inputs**
- User toggle/interval selections per notification type.

**Outputs**
- Updated notification configuration applied across all relevant reminder-generation logic.

**Preconditions**
- User is authenticated.

**Postconditions**
- All future notification generation respects the updated preferences.

**User Actions**
1. User navigates to Settings → Notification Preferences.
2. User toggles individual notification types on/off and adjusts intervals/timing where applicable.
3. User saves.

**System Behaviour**
- The system SHALL provide independent enable/disable control for each notification type defined in this section.
- The system SHALL apply preference changes immediately to future notification scheduling, including cancelling any already-scheduled notifications for a type the user disables.
- The system SHALL persist preferences locally and synchronize them to the cloud, consistent with Section 10.18.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-NPREF-01 | Disabling a notification type must result in no further notifications of that type being scheduled or delivered until re-enabled. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Save fails while offline | Persist changes locally and synchronize once connectivity is available. |

**Success Conditions**
- Notification Preferences accurately and immediately govern all notification generation behavior.

---

## 10.18 Offline Synchronization

### 10.18.1 Offline Data Storage

**Purpose**
To ensure all core application data remains fully available and modifiable without an internet connection.

**Description**
Offline Data Storage is the foundational requirement underlying the application's offline-first design, ensuring every tracking module (Feeding, Sleep, Diaper, Cry Analyzer history, Vaccination, Milestones, Growth, Gallery metadata) persists locally and functions independently of connectivity.

**Inputs**
- All user-generated data across tracking modules.

**Outputs**
- Fully persisted local data, available for read/write regardless of connectivity.

**Preconditions**
- The application has been used at least once while online to complete initial authentication and baby profile setup (see Section 10.1.6 for offline session handling).

**Postconditions**
- All core tracking functionality remains available offline, with data persisted locally pending synchronization.

**User Actions**
- User uses any tracking module normally while offline; no distinct action required.

**System Behaviour**
- The system SHALL persist all create/update/delete operations to local storage immediately, independent of connectivity.
- The system SHALL ensure no core tracking module (Sections 10.6–10.16) is blocked from full read/write functionality due to lack of connectivity, with the explicit exception of AI Chat (Section 10.15.1), which requires connectivity for inference.
- The system SHALL queue all offline changes for Cloud Synchronization (Section 10.18.3) upon reconnection.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ODS-01 | Every data-write operation must succeed locally regardless of network state, except where a specific module is explicitly defined as online-only (e.g., AI Chat). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Local storage write failure (e.g., device storage full) | Display a clear error and prevent data loss by not discarding the user's in-progress entry until successfully saved or explicitly cancelled. |

**Success Conditions**
- All core application functionality remains fully available and correctly persisted while offline.

---

### 10.18.2 SQLite Local Database

**Purpose**
To document the on-device structured storage mechanism underlying Offline Data Storage.

**Description**
The application's local data layer (Section 7.2) is implemented using an embedded relational database (SQLite), providing a structured, queryable, transactional local store mirroring the cloud schema, enabling reliable offline read/write and subsequent synchronization.

**Inputs**
- All structured application data (excluding large binary media files, which are stored via the device file system and referenced by path/identifier).

**Outputs**
- A consistent, queryable local database supporting all application read/write operations.

**Preconditions**
- Application is installed on a supported device.

**Postconditions**
- All structured data operations are transactionally persisted to the local database.

**User Actions**
- None; this is an internal storage mechanism not directly exposed to the user.

**System Behaviour**
- The system SHALL use a local relational database schema structurally aligned with the cloud database schema (see Database Requirements, addressed in a later part of this document) to minimize synchronization complexity.
- The system SHALL apply transactional writes to guarantee data integrity for multi-step operations (e.g., a Baby Registration flow spanning multiple tables).
- The system SHALL apply database migrations safely across application version upgrades, without data loss.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SQLITE-01 | Local database schema migrations must preserve all existing user data. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Local database corruption detected | Attempt automatic recovery from the last known-good state; if unrecoverable, prompt the user to restore from the most recent Cloud Synchronization state (Section 10.21.8 Backup & Restore). |

**Success Conditions**
- The local database reliably and consistently persists all structured application data across normal use and version upgrades.

---

### 10.18.3 Synchronization Queue

**Purpose**
To reliably track all pending local changes that have not yet been reconciled with the cloud data store.

**Description**
The Synchronization Queue records every create/update/delete operation performed while offline (or before successful cloud confirmation), ensuring no change is lost and every change is eventually transmitted to the cloud in the correct order.

**Inputs**
- Every local create/update/delete operation across all modules.

**Outputs**
- An ordered queue of pending changes awaiting synchronization.

**Preconditions**
- At least one local change has occurred that has not yet been confirmed as synchronized.

**Postconditions**
- All pending changes remain queued and are processed in order once synchronization proceeds (Sections 10.18.4–10.18.5).

**User Actions**
- None directly; the user may view Sync Status (Section 10.18.9), which reflects queue state.

**System Behaviour**
- The system SHALL append every local data-write operation to the Synchronization Queue at the time it occurs, tagged with a timestamp and operation type.
- The system SHALL process queued operations in chronological order during synchronization, unless Conflict Detection (Section 10.18.6) requires reordering/special handling.
- The system SHALL remove an operation from the queue only upon confirmed successful synchronization with the cloud.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SQ-01 | An operation must remain in the queue until the cloud service explicitly confirms successful application of that operation. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Queue grows unbounded due to prolonged offline use | Continue queuing without data loss; surface queue size/status to the user via Sync Status if it becomes unusually large. |

**Success Conditions**
- Every offline change is reliably captured in the queue and eventually and correctly synchronized, with no data loss.

---

### 10.18.4 Automatic Synchronization

**Purpose**
To reconcile local and cloud data automatically whenever connectivity becomes available, without requiring user intervention.

**Description**
Automatic Synchronization monitors device connectivity state and, upon detecting a usable connection, automatically begins processing the Synchronization Queue (Section 10.18.3) in the background.

**Inputs**
- Device connectivity state changes.
- Pending Synchronization Queue entries.

**Outputs**
- Reconciled local and cloud data stores; updated Sync Status.

**Preconditions**
- The device transitions from offline to online (or the application is opened while already online with pending queued changes).

**Postconditions**
- All queued changes are successfully applied to the cloud, and any relevant remote changes are pulled down to the local store.

**User Actions**
- None required; synchronization occurs automatically. User may observe progress via Sync Status.

**System Behaviour**
- The system SHALL detect connectivity restoration and automatically initiate synchronization without requiring explicit user action.
- The system SHALL process the Synchronization Queue in order, applying Conflict Detection/Resolution (Sections 10.18.6–10.18.7) as needed.
- The system SHALL pull down remote changes made by other devices/family members since the last successful sync.
- The system SHOULD respect user-configured constraints (e.g., Wi-Fi-only sync for large media) per Settings.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-AUTOSYNC-01 | Automatic Synchronization must not require any user action to begin once connectivity is available and preferences permit it. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Synchronization fails partway through | Retain unsynchronized items in the queue and apply the Retry Mechanism (Section 10.18.8). |

**Success Conditions**
- Local and cloud data are reliably and automatically reconciled whenever connectivity is available, without user intervention.

---

### 10.18.5 Manual Synchronization

**Purpose**
To allow users to explicitly trigger synchronization on demand, rather than waiting for automatic detection.

**Description**
Manual Synchronization provides a user-accessible "Sync Now" control, useful in cases where the user wants immediate confirmation that their data (or a family member's changes) is up to date.

**Inputs**
- User-initiated "Sync Now" action.

**Outputs**
- An immediately triggered synchronization cycle, with visible progress and completion status.

**Preconditions**
- Device has connectivity at the time of the manual trigger.

**Postconditions**
- All queued changes are processed and remote changes pulled down, consistent with Automatic Synchronization behavior.

**User Actions**
1. User navigates to Settings or Sync Status view.
2. User taps "Sync Now."
3. User observes synchronization progress and completion.

**System Behaviour**
- The system SHALL immediately attempt synchronization upon user request, using the same underlying process as Automatic Synchronization (Section 10.18.4).
- The system SHALL display real-time progress and a clear completion/failure result to the user.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-MANSYNC-01 | Manual Synchronization must not be triggerable while offline; the control must clearly indicate unavailability in that state. |

**Error Handling**

| Scenario | System Response |
|---|---|
| User triggers Manual Sync while offline | Display "No internet connection available" and disable the action until connectivity is restored. |
| Synchronization fails | Display a clear failure message and apply the Retry Mechanism (Section 10.18.8). |

**Success Conditions**
- Manual Synchronization reliably and immediately reconciles local and cloud data when triggered while online.

---

### 10.18.6 Conflict Detection

**Purpose**
To identify when the same data record has been modified independently on more than one device (or by more than one family member) before synchronization, requiring reconciliation.

**Description**
Conflict Detection compares the version/timestamp metadata of a locally queued change against the corresponding record's current state in the cloud at the time of synchronization, flagging a conflict when both have been independently modified since the last common synchronized state.

**Inputs**
- Local queued change and its base version/timestamp.
- Current cloud record state and its version/timestamp.

**Outputs**
- A conflict flag (with both conflicting versions available) when detected; otherwise, a clean apply.

**Preconditions**
- A synchronization cycle is in progress (Sections 10.18.4–10.18.5).
- The same record has been modified both locally and remotely since the last successful sync.

**Postconditions**
- Conflicting changes are identified and routed to Conflict Resolution (Section 10.18.7) rather than being silently overwritten.

**User Actions**
- None directly during detection; resolution may involve the user (Section 10.18.7).

**System Behaviour**
- The system SHALL maintain version or last-modified metadata on every synchronizable record sufficient to detect concurrent modification.
- The system SHALL compare local and remote versions for every queued change during synchronization, flagging a conflict whenever both differ from the last known common state.
- The system SHALL NOT silently apply a local or remote change over a detected conflict without passing through Conflict Resolution.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CDET-01 | Every synchronizable record must carry sufficient version metadata to make conflict detection possible. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Version metadata missing/corrupted for a record | Treat as a conflict conservatively (i.e., route to Conflict Resolution) rather than risking silent data loss. |

**Success Conditions**
- All genuine concurrent-modification conflicts are reliably detected and never silently overwritten.

---

### 10.18.7 Conflict Resolution

**Purpose**
To reconcile detected conflicts (Section 10.18.6) in a way that minimizes data loss and is predictable to the user.

**Description**
Conflict Resolution applies a defined resolution strategy to flagged conflicts — favoring non-destructive, additive resolution where possible (e.g., two independently added Feeding entries are both kept), and a clear, deterministic tie-breaking rule (e.g., last-write-wins with user notification) for true field-level conflicts on the same record.

**Inputs**
- Flagged conflicting local and remote versions of a record (Section 10.18.6).

**Outputs**
- A single reconciled record state applied to both local and cloud stores, with the losing version retained in a recoverable form where feasible.

**Preconditions**
- A conflict has been detected during synchronization.

**Postconditions**
- The conflict is resolved deterministically, and both local and cloud stores converge to the same reconciled state.

**User Actions**
- For field-level conflicts on the same record, the system SHOULD notify the user of the resolution taken; the user MAY be prompted to manually choose between versions for high-value records (e.g., Baby Profile fields).

**System Behaviour**
- The system SHALL treat additive operations (e.g., new log entries created independently on two devices) as non-conflicting and retain both.
- The system SHALL apply a last-write-wins strategy (based on modification timestamp) for true field-level conflicts on the same record, by default.
- The system SHALL retain the losing version temporarily (e.g., in Notification History or a conflict log) so the user can review and manually restore it if the automatic resolution was undesired.
- The system SHALL log all conflict resolutions for audit/diagnostic purposes.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-CRES-01 | Conflict Resolution must never result in silent, unrecoverable loss of either conflicting version; the losing version must be retained for a defined period. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Resolution itself fails (e.g., storage error while applying) | Retain the conflict in a pending state and retry via the Retry Mechanism (Section 10.18.8) rather than discarding either version. |

**Success Conditions**
- All detected conflicts are resolved deterministically and non-destructively, with local and cloud stores converging consistently.

---

### 10.18.8 Retry Mechanism

**Purpose**
To ensure synchronization operations that fail transiently are retried automatically rather than permanently abandoned.

**Description**
The Retry Mechanism applies an automatic, backoff-based retry strategy to failed synchronization operations (e.g., due to transient network loss or server error), ensuring eventual consistency without requiring manual user intervention.

**Inputs**
- Failed synchronization operations from the Synchronization Queue.

**Outputs**
- Automatically re-attempted synchronization operations at increasing intervals until success or a defined maximum retry limit.

**Preconditions**
- A synchronization operation has failed.

**Postconditions**
- The operation either eventually succeeds and is removed from the queue, or is flagged for Error Recovery (Section 10.18.10) after exhausting retries.

**User Actions**
- None required; retries occur automatically. User may observe status via Sync Status.

**System Behaviour**
- The system SHALL automatically retry a failed synchronization operation using an exponential backoff strategy.
- The system SHALL cap the retry interval and, after a defined maximum number of attempts, mark the operation as requiring Error Recovery rather than retrying indefinitely.
- The system SHALL resume normal retry behavior for all queued operations immediately upon detecting restored connectivity, regardless of backoff state.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-RETRY-01 | Retry attempts must not be abandoned silently; after exhausting automatic retries, the operation must be surfaced via Error Recovery. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Maximum retry attempts exhausted | Flag the operation for Error Recovery (Section 10.18.10) and surface it in Sync Status. |

**Success Conditions**
- Transient synchronization failures are reliably recovered from automatically, without data loss or requirement for user intervention.

---

### 10.18.9 Sync Status

**Purpose**
To provide users with clear, at-a-glance visibility into the current state of data synchronization.

**Description**
Sync Status displays whether the application is fully synchronized, has pending changes, is actively synchronizing, or has encountered an error requiring attention, surfaced both as a persistent indicator and within a dedicated Sync Status screen.

**Inputs**
- Current state of the Synchronization Queue (Section 10.18.3) and any flagged errors (Section 10.18.10).

**Outputs**
- A visual sync status indicator (e.g., icon/badge) and a detailed Sync Status screen.

**Preconditions**
- The application has completed initial setup.

**Postconditions**
- User has accurate, current visibility into synchronization state at all times.

**User Actions**
1. User views the persistent sync status indicator (e.g., in the navigation header).
2. User taps through to the detailed Sync Status screen for more information.

**System Behaviour**
- The system SHALL display a persistent, accessible (visual, not solely auditory) indicator reflecting one of: Fully Synced, Pending Changes, Syncing, or Sync Error.
- The system SHALL update this indicator in real time as synchronization state changes.
- The system SHALL provide a detailed Sync Status screen listing pending and failed operations, consistent with Synchronization Logs referenced in Section 3.2 (Offline Mode).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SYNCSTAT-01 | The displayed sync status must accurately reflect the true current state of the Synchronization Queue at all times, updated without requiring manual refresh. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Status indicator fails to update | Allow manual refresh via Manual Synchronization (Section 10.18.5) as a fallback. |

**Success Conditions**
- Sync Status accurately and promptly reflects the true synchronization state at all times.

---

### 10.18.10 Error Recovery

**Purpose**
To provide a clear path to resolution when synchronization errors cannot be automatically resolved through retries.

**Description**
Error Recovery surfaces synchronization operations that have exhausted the Retry Mechanism (Section 10.18.8) or encountered non-transient errors (e.g., a validation conflict requiring user input), presenting them clearly and offering user-actionable resolution options.

**Inputs**
- Operations flagged as failed after exhausting automatic retries or encountering non-transient errors.

**Outputs**
- A clear, actionable error listing within Sync Status, with resolution options (e.g., retry now, discard, view conflict detail).

**Preconditions**
- At least one synchronization operation has failed unrecoverably through automatic means.

**Postconditions**
- The user is able to view, understand, and act upon each unresolved synchronization error until resolved.

**User Actions**
1. User navigates to Sync Status and views flagged errors.
2. User selects a resolution action (e.g., "Retry Now," "View Details," or, for conflicts, "Keep Mine" / "Keep Other").
3. User confirms the chosen resolution.

**System Behaviour**
- The system SHALL clearly list each unresolved synchronization error with a plain-language description of the issue.
- The system SHALL offer at minimum a manual retry option for every listed error.
- The system SHALL, for data conflicts requiring user input (per Section 10.18.7), present both versions and allow the user to choose.
- The system SHALL remove an error from the list only once successfully resolved.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ERREC-01 | No synchronization error may be silently discarded without either automatic resolution or explicit user action. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Manual retry also fails | Retain the error in the list with updated failure detail and timestamp, allowing further retry attempts. |

**Success Conditions**
- All synchronization errors are clearly surfaced and reliably resolvable through user action, with no permanent silent data loss.

---

### 10.18.11 Background Synchronization

**Purpose**
To allow synchronization to proceed without requiring the application to be in the foreground/actively open.

**Description**
Background Synchronization leverages platform-provided background execution capabilities to perform synchronization cycles periodically or upon connectivity change, even while the application is not actively in use, subject to platform constraints and battery/data usage considerations.

**Inputs**
- Device connectivity state changes and elapsed time since last sync, evaluated by the operating system's background execution scheduler.

**Outputs**
- Synchronization cycles completed without requiring the user to open the application.

**Preconditions**
- The operating system permits background execution for the application (per platform policy and user device settings).

**Postconditions**
- Local and cloud data remain reasonably up to date even during periods when the application is not actively open.

**User Actions**
- None required; occurs automatically within platform constraints.

**System Behaviour**
- The system SHALL register for platform-appropriate background execution (e.g., background fetch/background sync APIs) to periodically process the Synchronization Queue.
- The system SHALL respect platform and user-configured constraints on background data usage (e.g., Wi-Fi-only background sync where configured).
- The system SHALL prioritize small, high-value data (structured records) over large media transfers during constrained background execution windows.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BGSYNC-01 | Background Synchronization must never consume background execution time/resources beyond platform-imposed limits in a way that causes the operating system to penalize the application. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Background execution denied or restricted by the OS/user | Fall back to Automatic Synchronization occurring upon next foreground app open (Section 10.18.4). |

**Success Conditions**
- Background Synchronization reliably keeps data reasonably current between active application sessions, within platform constraints, without adverse battery or data impact.

---

## 10.19 Search

### 10.19.1 Global Search

**Purpose**
To allow users to search across all tracked data types from a single, unified search entry point.

**Description**
Global Search provides an application-wide search bar that queries across Feeding, Sleep, Diaper, Cry History, Vaccination, Milestones, Growth Records, and Gallery captions/notes simultaneously, returning categorized results.

**Inputs**
- User-entered search query text.

**Outputs**
- A categorized list of matching results across all applicable modules.

**Preconditions**
- An active baby profile is selected.
- At least some data exists across tracked modules.

**Postconditions**
- User is presented with all matching results, grouped by module/category.

**User Actions**
1. User taps the Global Search entry point (e.g., from the Dashboard or main navigation).
2. User enters a query.
3. User reviews categorized results and taps an entry to navigate to its detail.

**System Behaviour**
- The system SHALL search across all text-searchable fields (notes, captions, names) and structured attributes (e.g., diaper type, milestone name) across all modules.
- The system SHALL group and label results by originating module (e.g., "Feeding," "Gallery," "Milestones").
- The system SHALL scope results strictly to the active baby profile, consistent with Data Separation (Section 10.4.4).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-GSEARCH-01 | Global Search results must only include data belonging to the active baby profile and permitted to the requesting user's role. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No matching results | Display "No results found" empty state. |
| Query too short (below minimum character threshold) | Defer search execution until the minimum threshold is met, or display a prompt to enter more characters. |

**Success Conditions**
- Global Search reliably and accurately returns all matching results across modules for a given query.

---

### 10.19.2 Search by Baby

**Purpose**
To allow a user managing multiple baby profiles to scope a search to a specific baby, or explicitly across all their accessible babies.

**Description**
Search by Baby provides a scope selector within Search, allowing the user to search within the currently active baby profile (default) or explicitly broaden the search across all baby profiles they have access to (e.g., when comparing twins, per Section 10.4).

**Inputs**
- User-selected baby scope (Active Baby / All Accessible Babies / a specific named baby).

**Outputs**
- Search results scoped accordingly, with each result labeled by its originating baby profile when scope spans multiple babies.

**Preconditions**
- User has access to at least one baby profile.

**Postconditions**
- Search results accurately reflect the selected baby scope.

**User Actions**
1. User opens Search.
2. User selects a baby scope from the available options.
3. User enters a query and reviews scoped results.

**System Behaviour**
- The system SHALL default search scope to the currently active baby profile.
- The system SHALL allow explicit broadening to all baby profiles the user has role-based access to, labeling each result with its source baby.
- The system SHALL enforce that only baby profiles the user is permitted to access (Section 10.20) are included, even when "All" scope is selected.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SBB-01 | Search results must never include a baby profile the requesting user does not have role-based access to. |

**Error Handling**

| Scenario | System Response |
|---|---|
| User has only one accessible baby profile | Omit or disable the "All Babies" scope option, as it would be equivalent to the default. |

**Success Conditions**
- Search by Baby accurately scopes results per the user's selection, without ever exposing unauthorized baby data.

---

### 10.19.3 Search by Date

**Purpose**
To allow users to constrain search results to a specific date or date range.

**Description**
Search by Date provides a date/date-range selector within Search, narrowing results to records timestamped within the specified period, usable in combination with a text query or independently to browse a specific day's records across modules.

**Inputs**
- User-selected date or date range.

**Outputs**
- Search results constrained to the selected date/date range.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- Search results accurately reflect the selected date constraint.

**User Actions**
1. User opens Search.
2. User selects a date or date range filter.
3. User reviews the constrained results.

**System Behaviour**
- The system SHALL filter all applicable record types by their associated timestamp against the selected date/range.
- The system SHALL allow Search by Date to be combined with a free-text query and/or Category filter (Section 10.19.4).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SBD-01 | Date range end must not be earlier than date range start. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invalid date range selected | Display inline validation error and prevent search execution until corrected. |
| No results within the selected date range | Display "No results found for the selected date range." |

**Success Conditions**
- Search by Date accurately constrains results to the selected period across all applicable modules.

---

### 10.19.4 Search by Category

**Purpose**
To allow users to constrain search results to one or more specific module categories.

**Description**
Search by Category provides a category selector (Feeding, Sleep, Diaper, Cry History, Vaccination, Milestones, Growth, Gallery) within Search, allowing users to focus results on the module(s) relevant to their query.

**Inputs**
- User-selected category or categories.

**Outputs**
- Search results constrained to the selected categories.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- Search results accurately reflect the selected category constraint.

**User Actions**
1. User opens Search.
2. User selects one or more category filters.
3. User reviews the constrained results.

**System Behaviour**
- The system SHALL allow selection of one, multiple, or all categories.
- The system SHALL allow Search by Category to be combined with a free-text query and/or Search by Date.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SBC-01 | Selected categories must be limited to the defined, valid set of module categories. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No results within the selected categories | Display "No results found for the selected categories." |

**Success Conditions**
- Search by Category accurately constrains results to the selected module(s).

---

### 10.19.5 Filters

**Purpose**
To provide a unified, combinable filtering mechanism spanning Search by Baby, Date, and Category, plus module-specific attributes.

**Description**
Filters consolidates Sections 10.19.2–10.19.4 into a single, coherent filter panel within Search, additionally allowing module-specific attribute filters where meaningful (e.g., filtering Diaper results specifically by Type).

**Inputs**
- User-selected combination of filter criteria across baby scope, date, category, and applicable module-specific attributes.

**Outputs**
- Search results reflecting all applied filters simultaneously.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- Search results accurately reflect the full combination of applied filters until cleared.

**User Actions**
1. User opens the Filters panel within Search.
2. User applies one or more filter criteria.
3. User applies the filter set and reviews results, or clears filters.

**System Behaviour**
- The system SHALL apply all selected filter criteria conjunctively (AND logic) to narrow results.
- The system SHALL clearly display currently active filters and provide a single control to clear all.
- The system SHALL persist applied filters for the duration of the search session.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FILT-01 | All individual filter validation rules (Sections 10.19.2–10.19.4) must be satisfied for the combined filter set to be considered valid. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Combined filters yield no results | Display "No results found for the selected filters" with a clear option to adjust or clear filters. |

**Success Conditions**
- Filters accurately and combinably narrow Search results per all criteria selected.

---

### 10.19.6 Sorting

**Purpose**
To allow users to control the order in which search results are presented.

**Description**
Sorting provides a sort-order selector within Search results (e.g., Most Recent First, Oldest First, Relevance), applicable across Global Search and any filtered/scoped result set.

**Inputs**
- User-selected sort order.

**Outputs**
- Search results reordered according to the selected criterion.

**Preconditions**
- At least one search result exists.

**Postconditions**
- Results remain sorted per the selected order for the duration of the search session, or until changed.

**User Actions**
1. User views search results.
2. User selects a sort order from the available options.
3. Results reorder accordingly.

**System Behaviour**
- The system SHALL default to reverse-chronological (Most Recent First) sort order.
- The system SHALL support at minimum Most Recent First, Oldest First, and Relevance (for free-text queries) sort options.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SORT-01 | Sort order selection must not alter the underlying result set, only its presentation order. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- Search results are reliably and correctly reordered per the user's selected sort criterion.

---

### 10.19.7 Search History

**Purpose**
To allow users to quickly re-run or reference their recent past search queries.

**Description**
Search History maintains a short, recent list of past search queries entered by the user, presented as quick-access suggestions when the Search interface is opened.

**Inputs**
- Previously submitted search queries by the authenticated user.

**Outputs**
- A list of recent search queries displayed as quick-access suggestions.

**Preconditions**
- The user has performed at least one prior search.

**Postconditions**
- Recent queries remain available for quick re-selection until the list naturally ages out or is cleared.

**User Actions**
1. User opens Search.
2. User views recent Search History suggestions.
3. User taps a past query to re-run it, or clears the history.

**System Behaviour**
- The system SHALL store a limited number of the user's most recent distinct search queries (e.g., last 10).
- The system SHALL allow the user to clear Search History at any time.
- The system SHALL scope Search History to the authenticated user, not shared across family members.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SHIST-01 | Search History must only be visible to the user who performed the searches. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- Search History accurately reflects the user's own recent queries and supports quick re-execution.

---

### 10.19.8 Quick Search

**Purpose**
To provide a lightweight, always-accessible search entry point optimized for fast, single-purpose lookups.

**Description**
Quick Search is a condensed search affordance (e.g., accessible from the Dashboard or a persistent search icon) optimized for rapid, common lookups (e.g., "last diaper change"), as distinct from the fuller Advanced Search experience (Section 10.19.9).

**Inputs**
- User-entered short query text.

**Outputs**
- A concise, immediate list of top matching results.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- User quickly obtains the most relevant result(s) without navigating to the full Search screen.

**User Actions**
1. User taps the Quick Search affordance.
2. User enters a short query.
3. User reviews the top results, optionally expanding to full Global Search for more.

**System Behaviour**
- The system SHALL return the top-ranked matching results as the user types, prioritizing recency and relevance.
- The system SHALL provide a clear path to expand into full Global Search/Advanced Search for a complete result set.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-QSEARCH-01 | Quick Search results must be scoped to the active baby profile by default, consistent with VR-GSEARCH-01. |

**Error Handling**

| Scenario | System Response |
|---|---|
| No matching results | Display a concise "No results" indicator. |

**Success Conditions**
- Quick Search reliably surfaces the most relevant top results with minimal interaction.

---

### 10.19.9 Advanced Search

**Purpose**
To provide a comprehensive search experience combining all available filtering, sorting, and scoping capabilities for precise, complex queries.

**Description**
Advanced Search consolidates Global Search (Section 10.19.1), all Filters (Section 10.19.5), and Sorting (Section 10.19.6) into a single dedicated screen, intended for users needing precise control over complex queries (e.g., preparing data for a pediatric visit).

**Inputs**
- Free-text query combined with any combination of baby scope, date range, category, module-specific attribute filters, and sort order.

**Outputs**
- A fully filtered, sorted, and scoped result set.

**Preconditions**
- An active baby profile is selected.

**Postconditions**
- User obtains a precise result set matching all specified criteria.

**User Actions**
1. User navigates to Advanced Search.
2. User configures query text and any combination of filters/sort order.
3. User reviews results and may export them (see Section 10.16) or navigate to individual entries.

**System Behaviour**
- The system SHALL present all available search, filter, and sort controls within a single coherent interface.
- The system SHALL apply the same underlying search/filter/sort logic as Sections 10.19.1–10.19.6, ensuring consistent behavior between Quick Search, Global Search, and Advanced Search.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ADVS-01 | Advanced Search must enforce the same access-scoping rules (VR-GSEARCH-01, VR-SBB-01) as all other Search entry points. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Combined criteria yield no results | Display "No results found" with a clear option to adjust criteria. |

**Success Conditions**
- Advanced Search reliably and accurately returns results precisely matching the full combination of specified criteria.

---

## 10.20 Family Sharing

### 10.20.1 Invite Family Members

**Purpose**
To allow a primary account holder to grant a family member (e.g., spouse, grandparent) access to a baby profile.

**Description**
Invite Family Members allows the user to send an invitation (via email, phone, or in-app link) to another individual, granting them access to the active baby profile upon acceptance, with an assigned role (Section 10.20.4).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Invitee Email or Phone Number | Text | Yes |
| Relationship/Role | Selection | Yes |
| Assigned Permission Level | Selection (Section 10.20.5–10.20.7) | Yes |

**Outputs**
- A dispatched invitation (email/SMS/in-app link).
- A pending invitation record associated with the baby profile.

**Preconditions**
- User holds Full Access permission for the baby profile being shared (Section 10.20.7).
- Device has network connectivity.

**Postconditions**
- An invitation is sent and remains pending until accepted, declined, or expired.

**User Actions**
1. User navigates to Family Sharing within Settings or Baby Profile.
2. User taps "Invite Family Member."
3. User enters invitee contact detail, relationship, and permission level.
4. User sends the invitation.

**System Behaviour**
- The system SHALL generate a unique, time-limited invitation token and dispatch it via the selected channel.
- The system SHALL create a pending invitation record, visible to the inviter, until accepted, declined, or expired.
- The system SHALL, upon acceptance, grant the invitee the assigned permission level for the specified baby profile(s).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-IFM-01 | Invitee contact detail must conform to a valid email or phone number format. |
| VR-IFM-02 | Only a user with Full Access may issue invitations. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invitee already has access | Display "This person already has access" and prevent duplicate invitation. |
| Invitation dispatch failure | Display error and allow retry. |

**Success Conditions**
- A valid invitation is successfully dispatched and, upon acceptance, correctly grants the specified access.

---

### 10.20.2 Invite Caregivers

**Purpose**
To allow a primary account holder to grant a non-family caregiver (e.g., babysitter) time-appropriate, scoped access to a baby profile.

**Description**
Invite Caregivers extends the invitation mechanism of Section 10.20.1 specifically for caregiver-role invitees, typically defaulting to a more restricted permission level appropriate for temporary, non-family caregivers.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Invitee Email or Phone Number | Text | Yes |
| Assigned Permission Level | Selection, defaulting to View Only or Edit Access | Yes |
| Access Expiry (optional) | Date/Time | No |

**Outputs**
- A dispatched invitation with caregiver-appropriate default permissions.

**Preconditions**
- User holds Full Access permission for the baby profile (Section 10.20.7).
- Device has network connectivity.

**Postconditions**
- An invitation is sent and, upon acceptance, grants the caregiver scoped, optionally time-limited access.

**User Actions**
1. User navigates to Family Sharing.
2. User taps "Invite Caregiver."
3. User enters invitee contact detail, permission level, and optional access expiry.
4. User sends the invitation.

**System Behaviour**
- The system SHALL default caregiver invitations to a restricted permission level (View Only or Edit Access, not Full Access) unless explicitly elevated by the inviter.
- The system SHALL support an optional access expiry date/time, after which the caregiver's access is automatically revoked.
- The system SHALL apply the same invitation dispatch mechanism as Section 10.20.1.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ICG-01 | Caregiver invitations must not default to Full Access permission. |
| VR-ICG-02 | Access Expiry, if provided, must be a future date/time. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Access Expiry in the past | Display validation error and prevent sending the invitation. |

**Success Conditions**
- Caregiver invitations are successfully dispatched with appropriately scoped, optionally time-bound permissions.

---

### 10.20.3 Invite Doctors

**Purpose**
To allow a primary account holder to grant a pediatrician or healthcare provider read-focused access to relevant baby records.

**Description**
Invite Doctors extends the invitation mechanism specifically for the Pediatrician persona (Section 9.3.1), typically scoped to View Only access over medically relevant modules (Vaccination, Growth, Milestones), and explicitly excluding administrative or family-management functions.

**Inputs**

| Field | Type | Required |
|---|---|---|
| Invitee Email | Text | Yes |
| Assigned Permission Level | Selection, defaulting to View Only | Yes |
| Scoped Modules (optional) | Multi-select (Vaccination, Growth, Milestones, etc.) | No |

**Outputs**
- A dispatched invitation with doctor-appropriate default permissions and scope.

**Preconditions**
- User holds Full Access permission for the baby profile.
- Device has network connectivity.

**Postconditions**
- An invitation is sent and, upon acceptance, grants the doctor scoped, typically read-only access.

**User Actions**
1. User navigates to Family Sharing.
2. User taps "Invite Doctor."
3. User enters the doctor's email and optionally scopes visible modules.
4. User sends the invitation.

**System Behaviour**
- The system SHALL default doctor invitations to View Only permission.
- The system SHALL support scoping doctor access to specific modules where module-level scoping is implemented, defaulting to medically relevant modules (Vaccination, Growth, Milestones) if no explicit scope is selected.
- The system SHALL exclude doctor-role users from Family Sharing management functions (e.g., inviting/removing other members) regardless of assigned permission level.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-IDOC-01 | Doctor-role invitees must never be granted Full Access permission, given the exclusion from family-management functions. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Invitee already has access | Display "This person already has access" and prevent duplicate invitation. |

**Success Conditions**
- Doctor invitations are successfully dispatched with appropriately scoped, read-focused access.

---

### 10.20.4 Role-Based Permissions

**Purpose**
To define the overarching permission model governing what each user role may view or do within a shared baby profile.

**Description**
Role-Based Permissions is the cross-cutting access-control framework underlying all Family Sharing functionality, defining the available permission levels (View Only, Edit Access, Full Access — Sections 10.20.5–10.20.7) and how they are enforced across every module in the application.

**Inputs**
- A user's assigned permission level for a given baby profile.
- The specific action/module the user is attempting to access.

**Outputs**
- An allow/deny determination for the requested action, enforced consistently across the application.

**Preconditions**
- The requesting user has been granted some level of access to the baby profile (Sections 10.20.1–10.20.3).

**Postconditions**
- The user's action is permitted or denied strictly according to their assigned Role-Based Permission level.

**User Actions**
- Implicit; the user simply uses the application, with available actions constrained by their permission level.

**System Behaviour**
- The system SHALL enforce Role-Based Permissions at the data access layer (not solely the UI layer), consistent with the enforcement principle established in Data Separation (VR-DS-02, Section 10.4.4).
- The system SHALL evaluate every data-read and data-write request against the requesting user's assigned permission level for the relevant baby profile before proceeding.
- The system SHALL apply the most specific applicable rule where module-level scoping exists (e.g., a doctor's scoped module access, Section 10.20.3).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-RBAC-01 | No action may be permitted based solely on UI-layer restriction; the underlying data access layer must independently enforce the same permission check. |

**Error Handling**

| Scenario | System Response |
|---|---|
| User attempts an action beyond their permission level | Deny the action and display a clear permission-denied message. |

**Success Conditions**
- Every action across the application is reliably and correctly governed by the requesting user's Role-Based Permission level.

---

### 10.20.5 View Only Access

**Purpose**
To define the most restricted permission level, allowing a user to view but not modify any baby profile data.

**Description**
View Only Access permits a user to read all data they are scoped to see (per Section 10.20.4) but blocks all create, update, and delete operations across every module.

**Inputs**
- N/A (a permission-level designation, not a user-entered input).

**Outputs**
- Read access granted; all write operations blocked for the user on the associated baby profile.

**Preconditions**
- A user has been granted View Only Access to a baby profile.

**Postconditions**
- The user can browse all permitted data but cannot alter it in any way.

**User Actions**
- User browses Dashboard, History, Reports, and other views normally; write-oriented controls (Add, Edit, Delete) are hidden or disabled.

**System Behaviour**
- The system SHALL hide or disable all write-oriented UI controls for a View Only user.
- The system SHALL reject any write request from a View Only user at the data access layer, even if attempted directly (defense in depth, consistent with VR-RBAC-01).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-VOA-01 | A View Only user must never be able to successfully complete a create, update, or delete operation on any in-scope data. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Write attempt bypassing UI restriction (e.g., via a stale cached screen) | Reject at the data layer and display a permission-denied message. |

**Success Conditions**
- View Only users reliably retain full read access and are reliably prevented from any write action.

---

### 10.20.6 Edit Access

**Purpose**
To define an intermediate permission level, allowing a user to log and modify day-to-day tracking data without granting administrative control over the baby profile or family-sharing settings.

**Description**
Edit Access permits a user to create, update, and delete records within tracking modules (Feeding, Sleep, Diaper, Cry Analyzer, Vaccination status updates, Milestones, Growth, Gallery) but excludes administrative actions such as editing core Baby Profile identity/medical fields, managing Family Sharing, or altering account/security Settings.

**Inputs**
- N/A (a permission-level designation).

**Outputs**
- Read/write access granted for tracking modules; administrative functions blocked.

**Preconditions**
- A user has been granted Edit Access to a baby profile.

**Postconditions**
- The user can fully participate in day-to-day logging and tracking but cannot alter administrative profile or sharing configuration.

**User Actions**
- User logs feeding, sleep, diaper, and other tracking entries normally; administrative controls (Edit Profile, Family Sharing management, Account Settings for the baby) are hidden or disabled.

**System Behaviour**
- The system SHALL grant full create/update/delete capability across all tracking modules to an Edit Access user.
- The system SHALL block Edit Access users from Baby Profile administrative edits (Section 10.13.9), Family Sharing management (Sections 10.20.1–10.20.3, 10.20.8), and baby-profile-level Settings.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-EDA-01 | An Edit Access user must never be able to successfully invite, remove, or modify the permissions of another family member. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Attempt to access an administrative function | Deny the action and display a permission-denied message. |

**Success Conditions**
- Edit Access users reliably retain full tracking read/write capability while being reliably restricted from administrative functions.

---

### 10.20.7 Full Access

**Purpose**
To define the highest permission level, granting complete control over a baby profile, including administrative and family-management functions.

**Description**
Full Access permits all capabilities available under Edit Access, plus Baby Profile administrative editing, Family Sharing management (inviting/removing members, changing permission levels), and baby-profile-scoped Settings. The user who completes initial Baby Registration (Section 10.3) is granted Full Access by default.

**Inputs**
- N/A (a permission-level designation).

**Outputs**
- Complete read/write/administrative access granted for the baby profile.

**Preconditions**
- A user has been granted Full Access to a baby profile (by default, the registering parent; otherwise by explicit grant from an existing Full Access holder).

**Postconditions**
- The user can perform any available action on the baby profile, including managing other users' access.

**User Actions**
- User performs any tracking, administrative, or sharing-management action without restriction.

**System Behaviour**
- The system SHALL grant Full Access users all capabilities of Edit Access plus administrative and family-management functions.
- The system SHALL require that at least one Full Access user remain associated with every baby profile at all times (i.e., the last Full Access user cannot remove their own access without first transferring it, to prevent an orphaned profile).

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-FUA-01 | A baby profile must always retain at least one user with Full Access. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Last Full Access user attempts to leave/remove their own access | Block the action and display a message requiring transfer of Full Access to another user first. |

**Success Conditions**
- Full Access users reliably retain complete control, and every baby profile reliably retains at least one Full Access holder at all times.

---

### 10.20.8 Remove Member

**Purpose**
To allow a Full Access user to revoke another user's access to a baby profile.

**Description**
Remove Member allows a Full Access holder to immediately and completely revoke a previously granted family member's, caregiver's, or doctor's access to the baby profile.

**Inputs**
- User selection of a member to remove, and confirmation action.

**Outputs**
- Immediate revocation of the selected member's access to the baby profile.

**Preconditions**
- Requesting user holds Full Access.
- The target member currently has some level of access to the baby profile.

**Postconditions**
- The removed member no longer has any access (read or write) to the baby profile, effective immediately.

**User Actions**
1. User navigates to Family Sharing → Member List.
2. User selects a member and taps "Remove."
3. User confirms the removal.

**System Behaviour**
- The system SHALL require explicit confirmation before removing a member's access, given its immediate and significant effect.
- The system SHALL immediately revoke all access (both for future actions and, where technically feasible, active sessions) upon confirmed removal.
- The system SHALL enforce VR-FUA-01 (Section 10.20.7), preventing removal of the last remaining Full Access user.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-REMOVE-01 | Removal must require explicit confirmation. |
| VR-REMOVE-02 | The last remaining Full Access user for a baby profile may not be removed (by themselves or others) without a prior transfer of Full Access. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Attempt to remove the last Full Access user | Block the action and display an explanatory message. |

**Success Conditions**
- Member removal reliably and immediately revokes all access for the targeted user, subject to the last-Full-Access-user safeguard.

---

### 10.20.9 Shared Notifications

**Purpose**
To ensure relevant notifications (reminders, alerts, activity updates) are appropriately delivered to all applicable members of a shared baby profile, not solely the original logging user.

**Description**
Shared Notifications extends the Notification System (Section 10.17) across all users with access to a baby profile, ensuring, for example, that a Vaccination Reminder or Missed Vaccination alert reaches every caregiver with appropriate permission, not just the user who set up the schedule.

**Inputs**
- Notification-triggering events (Sections 10.17.1–10.17.6) associated with a shared baby profile.
- The set of users currently holding access to that baby profile and their individual Notification Preferences (Section 10.17.10).

**Outputs**
- Notifications delivered to each eligible member according to their own preferences.

**Preconditions**
- A baby profile has more than one associated user.

**Postconditions**
- All eligible members receive relevant notifications independently, according to their own preferences.

**User Actions**
- Each member receives notifications per their own configured preferences; no coordinating action required between members.

**System Behaviour**
- The system SHALL deliver applicable notification types to every user with access to the relevant baby profile, filtered by each individual user's own Notification Preferences.
- The system SHALL NOT require one member's preference changes to affect another member's notification delivery.
- The system SHOULD indicate within Notification History (Section 10.17.9) when an activity was logged by a different family member (e.g., "Feeding logged by Dad"), for shared-awareness purposes.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SHNOT-01 | A notification must only be delivered to users who currently hold valid access to the associated baby profile at the time of delivery. |

**Error Handling**

| Scenario | System Response |
|---|---|
| A member's access is removed after a notification is queued but before delivery | Cancel delivery to that member. |

**Success Conditions**
- All eligible shared-profile members reliably receive applicable notifications according to their own individual preferences.

---

### 10.20.10 Shared Baby Records

**Purpose**
To ensure that all baby profile data is consistently and correctly visible (subject to permission level) to every authorized member of a shared baby profile, in real time.

**Description**
Shared Baby Records is the cross-cutting requirement ensuring that once a baby profile is shared (Sections 10.20.1–10.20.3), all subsequent data — whether logged by any member, on any device — becomes visible to every other authorized member, subject to their Role-Based Permission (Section 10.20.4) and normal synchronization behavior (Section 10.18).

**Inputs**
- Any data created, updated, or deleted by any authorized member of a shared baby profile.

**Outputs**
- Consistent, permission-appropriate visibility of all baby profile data across every authorized member's device, once synchronized.

**Preconditions**
- A baby profile has more than one associated user with active access.

**Postconditions**
- All authorized members observe a consistent, up-to-date view of the baby's records, subject to their own device's synchronization state.

**User Actions**
- Each member uses the application normally; shared visibility is automatic and requires no coordinating action.

**System Behaviour**
- The system SHALL treat all baby profile data as belonging to the baby profile itself, not to the individual user who created it, such that every authorized member's view reflects the same underlying dataset once synchronized.
- The system SHALL apply Role-Based Permissions (Section 10.20.4) uniformly to every member's view of Shared Baby Records.
- The system SHALL rely on Automatic/Background Synchronization (Sections 10.18.4, 10.18.11) to propagate changes across members' devices in a timely manner.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SBR-01 | No baby profile record may be permanently visible to only its originating user; all authorized members must eventually converge to the same visible dataset, subject to their permission level. |

**Error Handling**

| Scenario | System Response |
|---|---|
| A member's view is temporarily stale due to being offline | Reconcile automatically upon next successful synchronization (Section 10.18), with no permanent divergence. |

**Success Conditions**
- All authorized members of a shared baby profile reliably converge to a consistent, permission-appropriate view of all baby profile data.

---

## 10.21 Settings

### 10.21.1 Profile Settings

**Purpose**
To allow the authenticated user to view and manage their own personal account profile information.

**Description**
Profile Settings allows editing of the user's own account-level details (distinct from Parent Details/Baby Profile, Sections 10.2 and 10.13), such as display name, profile photo, and contact information used for authentication (Section 10.1).

**Inputs**

| Field | Type | Required |
|---|---|---|
| Display Name | Text | Yes |
| Profile Photo | Image | No |
| Email Address | Text | Yes (subject to re-verification if changed) |
| Phone Number | Text | No (subject to re-verification if changed) |

**Outputs**
- Updated user account profile record.

**Preconditions**
- User is authenticated.

**Postconditions**
- Updated profile information is reflected wherever the user's identity is displayed (e.g., Family Sharing member lists, Notification History attribution).

**User Actions**
1. User navigates to Settings → Profile Settings.
2. User edits display name, photo, email, or phone.
3. User saves.

**System Behaviour**
- The system SHALL apply the same validation rules to Email/Phone changes as initial Registration (Sections 10.1.1, 10.1.4), including re-verification where the value changes.
- The system SHALL propagate Display Name/Photo updates immediately across all views referencing the user.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PROFSET-01 | Email and Phone edits must satisfy the same format and uniqueness rules as initial registration. |

**Error Handling**

| Scenario | System Response |
|---|---|
| New email/phone already associated with another account | Display an appropriate conflict error and prevent save. |

**Success Conditions**
- Profile Settings are accurately updated and consistently reflected throughout the application.

---

### 10.21.2 Theme Settings

**Purpose**
To allow users to select a visual theme suited to their preference and environment.

**Description**
Theme Settings allows selection between Light, Dark, and System Default themes, supporting comfortable use across varying lighting conditions (e.g., nighttime feedings) and contributing to overall accessibility.

**Inputs**
- User-selected theme option (Light / Dark / System Default).

**Outputs**
- Application-wide visual theme updated accordingly.

**Preconditions**
- User is authenticated (or using the application in a guest/pre-authentication context where applicable).

**Postconditions**
- The selected theme is applied consistently across all screens and persisted across sessions.

**User Actions**
1. User navigates to Settings → Theme.
2. User selects Light, Dark, or System Default.
3. Theme applies immediately.

**System Behaviour**
- The system SHALL apply the selected theme immediately, without requiring an app restart.
- The system SHALL persist the theme preference locally and, once authenticated, synchronize it across the user's devices.
- The system SHALL ensure both Light and Dark themes independently satisfy the color-contrast and accessibility requirements defined later in this document.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-THEME-01 | Theme selection must be limited to the defined set of supported options. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- The selected theme is reliably and immediately applied and correctly persisted across sessions and devices.

---

### 10.21.3 Language Settings

**Purpose**
To allow users to select their preferred display language for the application interface.

**Description**
Language Settings allows selection from the application's supported language set, applied to all interface text, labels, and (where feasible) AI Assistant interaction.

**Inputs**
- User-selected language from the supported list.

**Outputs**
- Application-wide interface language updated accordingly.

**Preconditions**
- User is authenticated.

**Postconditions**
- The selected language is applied consistently across all screens and persisted across sessions.

**User Actions**
1. User navigates to Settings → Language.
2. User selects a language from the supported list.
3. Interface language updates accordingly.

**System Behaviour**
- The system SHALL apply the selected language across all static interface text immediately.
- The system SHALL persist the language preference locally and synchronize it across the user's devices.
- The system SHOULD default to the device's system language at first launch where supported, falling back to a defined default language otherwise.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-LANG-01 | Language selection must be limited to the application's officially supported language set. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Selected language's translation resources fail to load | Fall back to the default language and display a non-blocking notice. |

**Success Conditions**
- The selected language is reliably and consistently applied across the interface and correctly persisted.

---

### 10.21.4 Notification Preferences

**Purpose**
To provide the Settings-module entry point into the notification configuration capability already fully specified under the Notification System.

**Description**
This entry, within Settings, cross-references the complete Notification Preferences functional requirements already defined in Section 10.17.10, ensuring users can discover and configure notification behavior from the Settings module as expected by standard application navigation conventions.

**Inputs**
- (See Section 10.17.10.)

**Outputs**
- (See Section 10.17.10.)

**Preconditions**
- (See Section 10.17.10.)

**Postconditions**
- (See Section 10.17.10.)

**User Actions**
1. User navigates to Settings → Notification Preferences.
2. (Continues as specified in Section 10.17.10.)

**System Behaviour**
- The system SHALL surface the full Notification Preferences functionality specified in Section 10.17.10 from within the Settings module, with no divergence in behavior between entry points.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-NPSET-01 | Notification Preferences behavior must be identical regardless of navigation entry point (Settings or Notification Center). |

**Error Handling**

| Scenario | System Response |
|---|---|
| (See Section 10.17.10.) | (See Section 10.17.10.) |

**Success Conditions**
- Users can reliably access and configure full Notification Preferences functionality from within Settings.

---

### 10.21.5 Privacy Settings

**Purpose**
To allow users to control how their data and their baby's data is used, particularly regarding optional data-driven personalization features.

**Description**
Privacy Settings allows the user to enable or disable optional personalization behaviors (e.g., AI Assistant referencing logged data, per Sections 10.15.3–10.15.6) and to review a summary of what data is collected and how it is used.

**Inputs**
- User toggle selections for optional personalization/data-use features.

**Outputs**
- Updated privacy configuration applied across relevant features.

**Preconditions**
- User is authenticated.

**Postconditions**
- All relevant features respect the updated privacy configuration going forward.

**User Actions**
1. User navigates to Settings → Privacy Settings.
2. User reviews data-use information and toggles optional personalization features.
3. User saves.

**System Behaviour**
- The system SHALL provide independent toggles for each optional data-use/personalization feature (e.g., AI Assistant personalization).
- The system SHALL apply privacy preference changes immediately to future feature behavior.
- The system SHALL provide a clear, accessible summary of data collection and usage practices within this screen.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-PRIV-01 | Disabling a personalization feature must immediately stop that feature from referencing the user's logged data. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Save fails while offline | Persist changes locally and synchronize once connectivity is available. |

**Success Conditions**
- Privacy Settings accurately and immediately govern all optional data-use/personalization behavior.

---

### 10.21.6 Security Settings

**Purpose**
To allow users to manage security-related account controls.

**Description**
Security Settings allows the user to change their password, review active sessions/devices, and manage any additional security features (e.g., biometric app-lock), consolidating security-related self-service actions in one place.

**Inputs**
- User actions: change password request, session review, biometric lock toggle.

**Outputs**
- Updated security configuration; ability to remotely terminate other active sessions.

**Preconditions**
- User is authenticated.

**Postconditions**
- Updated security settings are applied and, where applicable, other sessions are affected immediately.

**User Actions**
1. User navigates to Settings → Security Settings.
2. User may initiate a password change (routing through Section 10.1.5 logic while authenticated), review active sessions, or toggle biometric app-lock.
3. User saves/confirms changes.

**System Behaviour**
- The system SHALL allow an authenticated user to change their password, applying the same complexity validation as VR-REG-04.
- The system SHALL display a list of active sessions/devices where technically feasible, with an option to remotely terminate any session other than the current one.
- The system SHALL support enabling device-level biometric app-lock as an additional access control layer, where supported by the device.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-SECSET-01 | Password changes must satisfy the same complexity rules as VR-REG-04 and VR-PR-02. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Remote session termination fails | Display error and allow retry. |

**Success Conditions**
- Security Settings reliably allow the user to manage password, sessions, and biometric lock as intended.

---

### 10.21.7 Accessibility Settings

**Purpose**
To allow users to configure the application's accessibility behavior to their specific needs, particularly for deaf and hard-of-hearing users.

**Description**
Accessibility Settings consolidates all user-configurable accessibility options — visual alert intensity, haptic/vibration notification strength, font size, color-indicator style, and reduced text-complexity mode — into a single, discoverable location, directly supporting the accessibility-first design principles established in Sections 9.6 and elaborated in the Accessibility Requirements section later in this document.

**Inputs**
- User selections for font size, vibration pattern/intensity, visual alert style, and text-complexity mode.

**Outputs**
- Updated accessibility configuration applied application-wide.

**Preconditions**
- User is authenticated.

**Postconditions**
- All application screens and notification delivery reflect the updated accessibility configuration.

**User Actions**
1. User navigates to Settings → Accessibility Settings.
2. User adjusts font size, vibration, visual alert, and text-complexity preferences.
3. Changes apply immediately.

**System Behaviour**
- The system SHALL apply font size adjustments across all application text immediately, without requiring a restart.
- The system SHALL apply the selected vibration pattern/intensity to all Local and Push Notifications (Sections 10.17.7–10.17.8).
- The system SHALL apply the selected visual alert style consistently across Cry Analyzer results, notifications, and status indicators.
- The system SHALL, when reduced text-complexity mode is enabled, favor icon-driven and simplified-language presentation across the interface where alternate phrasing has been defined.
- The system SHALL pre-populate sensible accessibility defaults based on the accessibility preference indicated during Parent Registration (Section 10.2), while remaining fully user-adjustable thereafter.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ACCSET-01 | Accessibility Settings changes must apply consistently across every screen and notification channel, with no exempted areas. |

**Error Handling**

| Scenario | System Response |
|---|---|
| N/A | N/A |

**Success Conditions**
- Accessibility Settings reliably and consistently govern the application's visual, haptic, and textual presentation per the user's configuration.

---

### 10.21.8 Backup & Restore

**Purpose**
To allow users to explicitly trigger a full backup of their local data and, where necessary, restore their data from the cloud.

**Description**
Backup & Restore provides user-facing controls layered on top of the underlying Cloud Synchronization infrastructure (Section 10.18), allowing an explicit "Back Up Now" action and a "Restore from Cloud" action (e.g., when setting up a new device).

**Inputs**
- User-initiated Backup or Restore action.

**Outputs**
- A completed backup of current local data to the cloud, or a completed restoration of cloud data to the local device.

**Preconditions**
- User is authenticated.
- Device has network connectivity.

**Postconditions**
- For Backup: all current local data is confirmed present in the cloud.
- For Restore: all cloud data for the user's accessible baby profile(s) is present on the local device.

**User Actions**
1. User navigates to Settings → Backup & Restore.
2. User taps "Back Up Now" or "Restore from Cloud."
3. User observes progress and completion confirmation.

**System Behaviour**
- The system SHALL, on "Back Up Now," immediately process the full Synchronization Queue (Section 10.18.3), equivalent to Manual Synchronization (Section 10.18.5).
- The system SHALL, on "Restore from Cloud," pull down all cloud data for the user's accessible baby profiles into the local database, used primarily during new-device setup.
- The system SHALL display clear progress and completion/failure status for both operations.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-BAKRES-01 | Backup and Restore actions must not be triggerable while offline; the controls must clearly indicate unavailability in that state. |

**Error Handling**

| Scenario | System Response |
|---|---|
| Action triggered while offline | Display "No internet connection available" and disable the action. |
| Backup/Restore fails partway | Display a clear failure message and allow retry, without discarding any local data. |

**Success Conditions**
- Backup and Restore actions reliably and completely reconcile local and cloud data as intended when triggered.

---

### 10.21.9 Data Export

**Purpose**
To provide the Settings-module entry point into data export capability, consolidating access to PDF and CSV export across all modules.

**Description**
Data Export, within Settings, provides a unified entry point to export the user's full dataset (or a selected module/date range) as PDF or CSV, cross-referencing the export mechanisms already specified under Reports and Analytics (Sections 10.16.10–10.16.11) and Growth Records (Section 10.14.7).

**Inputs**
- User-selected export scope (module, date range) and format (PDF/CSV).

**Outputs**
- A generated export file, consistent with Sections 10.16.10–10.16.11.

**Preconditions**
- (See Sections 10.16.10–10.16.11.)

**Postconditions**
- (See Sections 10.16.10–10.16.11.)

**User Actions**
1. User navigates to Settings → Data Export.
2. User selects scope and format.
3. (Continues as specified in Sections 10.16.10–10.16.11.)

**System Behaviour**
- The system SHALL surface the same underlying PDF/CSV export functionality specified in Sections 10.16.10–10.16.11 from within Settings, with no divergence in behavior between entry points.
- The system SHALL additionally support a "Full Export" scope, compiling all modules for the active baby profile into a single export package.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-DEXP-01 | Data Export behavior must be identical to the equivalent Section 10.16 export functionality regardless of navigation entry point. |

**Error Handling**

| Scenario | System Response |
|---|---|
| (See Sections 10.16.10–10.16.11.) | (See Sections 10.16.10–10.16.11.) |

**Success Conditions**
- Users can reliably access complete data export functionality, including full-dataset export, from within Settings.

---

### 10.21.10 Account Management

**Purpose**
To allow users to manage the lifecycle of their account, including deactivation and deletion.

**Description**
Account Management provides controls for account-level actions beyond Profile Settings (Section 10.21.1), specifically account deactivation (temporary) and account deletion (permanent), including the necessary data-handling implications for shared baby profiles.

**Inputs**
- User-initiated deactivation or deletion request, with confirmation.

**Outputs**
- Account deactivated (recoverable) or deleted (permanent, subject to retention rules).

**Preconditions**
- User is authenticated.

**Postconditions**
- For Deactivation: the account is inaccessible until reactivated, per a defined process.
- For Deletion: the account and its exclusively-owned data are permanently removed, subject to VR-FUA-01 (Section 10.20.7) safeguards for shared baby profiles.

**User Actions**
1. User navigates to Settings → Account Management.
2. User selects Deactivate or Delete Account.
3. User confirms via a robust confirmation step (e.g., re-entering password).

**System Behaviour**
- The system SHALL require password re-entry or equivalent strong confirmation before processing deactivation or deletion.
- The system SHALL, upon deletion, enforce VR-FUA-01: if the deleting user is the last Full Access holder of any baby profile, the system SHALL require the user to first transfer Full Access or explicitly confirm deletion of that baby profile's data.
- The system SHALL clearly explain, before final confirmation, what data will be affected for each linked baby profile.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-ACCTMGT-01 | Account deletion must require strong re-authentication confirmation immediately prior to execution. |
| VR-ACCTMGT-02 | Account deletion must not silently orphan a shared baby profile (consistent with VR-FUA-01). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Re-authentication fails | Deny the action and display an appropriate error. |
| Deleting user is the last Full Access holder of a shared profile | Block deletion of that association until Full Access is transferred or explicit data-deletion consent is given. |

**Success Conditions**
- Account deactivation and deletion are reliably and safely processed, with shared baby profiles never left without a Full Access holder unintentionally.

---

### 10.21.11 Logout

**Purpose**
To allow users to explicitly end their authenticated session on the current device.

**Description**
Logout provides the user-facing trigger for the session termination behavior already specified under Session Management (Section 10.1.6), clearing locally stored credentials and returning the user to the Login screen.

**Inputs**
- User-initiated Logout action.

**Outputs**
- Terminated session; locally stored authentication credentials cleared.

**Preconditions**
- User is authenticated.

**Postconditions**
- The user is signed out on the current device and must re-authenticate to regain access.

**User Actions**
1. User navigates to Settings → Logout.
2. User confirms the logout action.
3. User is returned to the Login screen.

**System Behaviour**
- The system SHALL require a lightweight confirmation step before executing Logout, to prevent accidental triggering.
- The system SHALL execute the full session-termination behavior defined in Section 10.1.6 upon confirmed Logout.
- The system SHALL retain all locally stored application data (per Offline Data Storage, Section 10.18.1) across Logout, clearing only authentication credentials, such that re-login on the same device does not require re-downloading previously synchronized data unless explicitly cleared.

**Validation Rules**

| Rule ID | Rule |
|---|---|
| VR-LOGOUT-01 | Logout must fully clear locally stored session credentials, consistent with VR-SESS-03 (Section 10.1.6). |

**Error Handling**

| Scenario | System Response |
|---|---|
| Logout attempted while a synchronization is in progress | Warn the user that pending changes may not be fully synchronized and offer to wait for sync completion before logging out. |

**Success Conditions**
- Logout reliably and completely terminates the authenticated session on the current device, returning the user to the Login screen.

---

# 11. Non-Functional Requirements

## 11.0 Section Conventions

Non-Functional Requirements (NFRs) in this section are uniquely identified using the format NFR-[Category]-[Number] (e.g., NFR-PERF-01), consistent with the conventions established in Section 1.4 and Section 10.0. Each NFR uses **MUST/SHALL**, **SHOULD**, or **MAY** to indicate priority, and, where meaningful, includes a measurable target to support objective verification during testing.

## 11.1 Performance

### 11.1.1 Response Time

| ID | Requirement |
|---|---|
| NFR-PERF-01 | The system SHALL render any screen transition triggered by primary navigation (Section 10.5.6) within 500 milliseconds under normal operating conditions on a mid-tier reference device. |
| NFR-PERF-02 | The system SHALL complete any local data-write operation (e.g., saving a Feeding, Sleep, or Diaper entry) within 300 milliseconds, exclusive of any network-dependent Cloud Synchronization step. |
| NFR-PERF-03 | The system SHALL provide immediate visual feedback (e.g., loading indicator) for any operation expected to take longer than 300 milliseconds, consistent with accessibility-first, non-auditory feedback principles (Section 9.6). |

### 11.1.2 Startup Time

| ID | Requirement |
|---|---|
| NFR-PERF-04 | The application SHALL reach an interactive Dashboard or Login screen within 3 seconds of a cold start on a mid-tier reference device. |
| NFR-PERF-05 | The application SHALL reach an interactive state within 1.5 seconds on a warm start (resume from background) under normal operating conditions. |

### 11.1.3 AI Prediction Time

| ID | Requirement |
|---|---|
| NFR-PERF-06 | The system SHALL complete the full Cry Analyzer pipeline (Audio Validation through AI Prediction, Sections 10.6.3–10.6.8) and display a result within 5 seconds of submission under normal network conditions, for audio at the maximum supported duration. |
| NFR-PERF-07 | The system SHALL display a clear, accessible progress indicator throughout AI Prediction processing, consistent with NFR-PERF-03. |
| NFR-PERF-08 | The system SHALL time out and display a retry-capable error state (Section 10.6.8 Error Handling) if AI Prediction has not completed within 15 seconds. |

### 11.1.4 Database Performance

| ID | Requirement |
|---|---|
| NFR-PERF-09 | Local (SQLite) queries for any single module's History or Statistics view (Sections 10.6–10.9) SHALL return results within 200 milliseconds for a baby profile with up to 5 years of accumulated daily-use data. |
| NFR-PERF-10 | Cloud (PostgreSQL) queries backing Reports and Analytics (Section 10.16) SHALL return results within 2 seconds under normal load for the same data volume. |

### 11.1.5 Synchronization Performance

| ID | Requirement |
|---|---|
| NFR-PERF-11 | The system SHALL synchronize a typical day's incremental structured data changes (excluding large media) within 5 seconds under normal connectivity conditions. |
| NFR-PERF-12 | The system SHALL prioritize synchronization of structured records over media file uploads, so that Sync Status (Section 10.18.9) can reflect structured-data completeness independent of ongoing media backup. |

### 11.1.6 Scalability (Performance Dimension)

| ID | Requirement |
|---|---|
| NFR-PERF-13 | The system SHALL maintain the response time targets defined in Sections 11.1.1–11.1.5 as the number of babies managed under a single family account grows to at least 5 (covering realistic multi-child and twin/multiple scenarios, Section 10.4). |
| NFR-PERF-14 | The backend service layer SHALL be architected to scale horizontally to accommodate growth in concurrent users, consistent with the broader Scalability non-functional requirements defined in Section 11.5. |

## 11.2 Reliability

### 11.2.1 Fault Tolerance

| ID | Requirement |
|---|---|
| NFR-REL-01 | A failure in any single non-critical module (e.g., Gallery thumbnail rendering, Section 10.12.4) SHALL NOT cause the failure or crash of unrelated modules or the application as a whole. |
| NFR-REL-02 | The system SHALL degrade gracefully when a dependent external service (AI inference, push notification gateway, cloud storage) is unavailable, preserving all offline-capable functionality per Section 10.18. |

### 11.2.2 Error Recovery

| ID | Requirement |
|---|---|
| NFR-REL-03 | The system SHALL apply the Retry Mechanism and Error Recovery behavior defined in Sections 10.18.8 and 10.18.10 to all recoverable synchronization and network failures. |
| NFR-REL-04 | The system SHALL never discard a user's in-progress, unsaved input as a result of a transient error; the user SHALL be able to retry submission without re-entering data. |

### 11.2.3 Data Integrity

| ID | Requirement |
|---|---|
| NFR-REL-05 | The system SHALL apply transactional writes for any multi-step data operation (e.g., Twin Baby Registration, Section 10.4), ensuring partial failures do not leave the data store in an inconsistent state. |
| NFR-REL-06 | The system SHALL enforce Data Separation (Section 10.4.4) and Role-Based Permissions (Section 10.20.4) at the data access layer as a reliability and integrity safeguard, not solely a security control. |

### 11.2.4 Backup

| ID | Requirement |
|---|---|
| NFR-REL-07 | The system SHALL maintain automated, regular backups of the cloud (PostgreSQL) data store, independent of user-initiated Backup & Restore actions (Section 10.21.8), with a defined recovery point objective (RPO) of no more than 24 hours. |
| NFR-REL-08 | The system SHALL retain automated backups for a defined minimum retention period sufficient to support recovery from undetected data corruption. |

### 11.2.5 Availability

| ID | Requirement |
|---|---|
| NFR-REL-09 | The backend service layer SHALL target a minimum monthly uptime of 99.5% for cloud-dependent functions (AI Chat, Cloud Synchronization, Family Sharing invitation dispatch). |
| NFR-REL-10 | Core offline-capable tracking functionality (Sections 10.6–10.9, 10.11–10.14) SHALL remain available with effectively 100% availability from the user's perspective, independent of backend service uptime, consistent with Offline Mode requirements (Section 10.18). |

## 11.3 Usability

### 11.3.1 Easy Navigation

| ID | Requirement |
|---|---|
| NFR-USE-01 | Every major functional module SHALL be reachable from the Dashboard within a maximum of two navigation actions, consistent with VR-NAV-01 (Section 10.5.6). |
| NFR-USE-02 | The system SHALL maintain a persistent, clearly visible indication of the currently active baby profile and current navigation location at all times. |

### 11.3.2 User-Friendly Design

| ID | Requirement |
|---|---|
| NFR-USE-03 | Common logging actions (Feeding, Sleep, Diaper, Quick Actions, Section 10.5.3) SHALL be completable in no more than 3 user interactions (taps/selections) from the Dashboard under default configuration. |
| NFR-USE-04 | The system SHALL apply smart defaults (e.g., current time pre-filled) wherever feasible to minimize required user input, consistent with Section 10.5.3. |

### 11.3.3 Minimal Learning Curve

| ID | Requirement |
|---|---|
| NFR-USE-05 | The system SHALL be usable for core daily-use tracking tasks (Feeding, Sleep, Diaper logging) by a first-time user without requiring an onboarding tutorial, relying on self-evident iconography and labeling. |
| NFR-USE-06 | The system SHOULD provide optional, dismissible contextual guidance (e.g., first-use tooltips) for less frequently used or more complex modules (e.g., Twin Registration, Family Sharing), without blocking access for users who choose to skip it. |

### 11.3.4 Consistent UI

| ID | Requirement |
|---|---|
| NFR-USE-07 | The system SHALL apply a single, consistent design system (component styles, iconography, terminology, and interaction patterns) across all modules, consistent with the Data Visualization consistency principle established in Section 10.16.12. |
| NFR-USE-08 | Equivalent actions (e.g., "Save," "Delete," "Edit") SHALL use consistent labeling, iconography, and placement across all modules. |

### 11.3.5 Responsive Design

| ID | Requirement |
|---|---|
| NFR-USE-09 | The user interface SHALL render correctly and remain fully usable across the range of supported device screen sizes (Section 11.6), without truncated content, overlapping elements, or required horizontal scrolling in core views. |
| NFR-USE-10 | The user interface SHALL adapt layout appropriately for tablet form factors (Section 11.6.3), making effective use of additional available screen space rather than simply scaling a phone layout. |

## 11.4 Maintainability

### 11.4.1 Modular Architecture

| ID | Requirement |
|---|---|
| NFR-MAINT-01 | The system SHALL be architected using clearly bounded modules aligned with the functional modules defined in Section 10 (e.g., a distinct module boundary per Feeding, Sleep, Diaper, Cry Analyzer, etc.), minimizing cross-module coupling. |
| NFR-MAINT-02 | Shared cross-cutting concerns (Authentication, Role-Based Permissions, Offline Synchronization, Notification delivery) SHALL be implemented as shared services consumed by feature modules, rather than duplicated per module. |

### 11.4.2 Clean Code

| ID | Requirement |
|---|---|
| NFR-MAINT-03 | Implementation code (outside the scope of this document, but governed by it) SHALL adhere to a defined, enforced coding standard and style guide per platform/language used. |
| NFR-MAINT-04 | Automated static analysis/linting SHOULD be integrated into the development workflow to enforce coding standards prior to merge. |

### 11.4.3 Documentation

| ID | Requirement |
|---|---|
| NFR-MAINT-05 | Each functional module SHALL have corresponding technical documentation (architecture, API contracts, data schema) maintained alongside this SRS, consistent with the Related Internal Documents identified in Section 5.3. |
| NFR-MAINT-06 | API endpoints (Section 12.5) SHALL be documented in a machine-readable specification format to support consistent client-backend integration and testing. |

### 11.4.4 Logging

| ID | Requirement |
|---|---|
| NFR-MAINT-07 | The backend service layer SHALL log all significant operations (authentication events, synchronization cycles, AI inference invocations, security-relevant actions per Section 14) with sufficient detail to support diagnosis, without logging sensitive personal data in plain text. |
| NFR-MAINT-08 | Client-side error logging SHALL be captured and (subject to user privacy preferences, Section 10.21.5) transmitted to a diagnostic backend to support issue triage. |

### 11.4.5 Monitoring

| ID | Requirement |
|---|---|
| NFR-MAINT-09 | The backend service layer SHALL be instrumented with monitoring covering the Availability targets defined in Section 11.2.5, with alerting for threshold breaches. |
| NFR-MAINT-10 | Key operational metrics (API latency, AI inference latency, synchronization failure rate, notification delivery success rate) SHALL be tracked to support ongoing performance and reliability management. |

## 11.5 Scalability

### 11.5.1 Multiple Babies

| ID | Requirement |
|---|---|
| NFR-SCALE-01 | The system SHALL support management of multiple, independently tracked baby profiles under a single family account without degradation of performance targets defined in Section 11.1, consistent with Section 10.4. |

### 11.5.2 Twin Support

| ID | Requirement |
|---|---|
| NFR-SCALE-02 | The system SHALL support simultaneous, independent tracking for twin/multiple-birth babies (Section 10.4) with full data separation and no cross-profile performance penalty. |

### 11.5.3 Large User Base

| ID | Requirement |
|---|---|
| NFR-SCALE-03 | The backend architecture SHALL be designed to scale to support growth toward public app store distribution (Section 6.4), using horizontally scalable service and database infrastructure rather than architecture requiring redesign at moderate user growth. |
| NFR-SCALE-04 | The AI inference subsystem (Cry Analyzer, AI Assistant) SHALL be architected to scale inference capacity independently of the core backend API service, given its distinct resource profile (e.g., GPU/accelerated compute needs). |

### 11.5.4 Future Features

| ID | Requirement |
|---|---|
| NFR-SCALE-05 | The system's modular architecture (Section 11.4.1) and database schema (Section 13) SHALL accommodate the Future Scope items identified in Section 16 (e.g., wearable/device integrations, hospital/EHR integrations) without requiring fundamental architectural redesign. |

## 11.6 Portability

### 11.6.1 Android

| ID | Requirement |
|---|---|
| NFR-PORT-01 | The application SHALL be fully functional on the current and immediately preceding major Android OS release, in accordance with the Google Play Store distribution target identified in Section 6.4. |

### 11.6.2 iOS

| ID | Requirement |
|---|---|
| NFR-PORT-02 | The application SHALL be fully functional on the current and immediately preceding major iOS release, in accordance with the Apple App Store distribution target identified in Section 6.4. |

### 11.6.3 Tablet

| ID | Requirement |
|---|---|
| NFR-PORT-03 | The application SHALL be fully functional and appropriately laid out (Section 11.3.5) on supported Android and iOS tablet form factors. |

### 11.6.4 Web

| ID | Requirement |
|---|---|
| NFR-PORT-04 | A web-based companion interface, if provided, SHOULD support core read/review functionality (e.g., Dashboard, History, Reports) using the same backend API defined in Section 12.5, without requiring backend-layer changes specific to the web client. This capability is identified as a scalability-oriented design allowance and is not a mandatory deliverable of the initial release. |

---

# 12. External Interface Requirements

## 12.1 User Interface

| ID | Requirement |
|---|---|
| EIR-UI-01 | The system SHALL provide a mobile application user interface implementing all modules defined in Section 10, consistent with the accessibility-first, low-text-complexity design principles established in Sections 9.6 and 15. |
| EIR-UI-02 | The user interface SHALL support both Light and Dark themes (Section 10.21.2) and dynamic font scaling (Section 10.21.7). |
| EIR-UI-03 | The user interface SHALL present a persistent primary navigation structure (Section 10.5.6) and a persistent baby-profile/sync-status indicator (Sections 10.4.3, 10.18.9). |

## 12.2 Hardware Interface

| ID | Requirement |
|---|---|
| EIR-HW-01 | The system SHALL interface with the device microphone to support Live Recording for the Cry Analyzer (Section 10.6.1). |
| EIR-HW-02 | The system SHALL interface with the device camera to support Photo/Video capture for Gallery and Milestone attachments (Sections 10.11.4–10.11.5, 10.12.1–10.12.2). |
| EIR-HW-03 | The system SHALL interface with the device's vibration/haptic hardware to support accessibility-first notification delivery (Sections 10.17.7–10.17.8, 15). |
| EIR-HW-04 | The system SHALL interface with local device storage for Offline Data Storage (Section 10.18.1) and cached media. |
| EIR-HW-05 | The system SHOULD interface with device biometric hardware (fingerprint/face recognition), where available, to support optional app-lock (Section 10.21.6). |

## 12.3 Software Interface

| ID | Requirement |
|---|---|
| EIR-SW-01 | The system SHALL interface with the device operating system's notification framework for Local and Push Notification delivery (Sections 10.17.7–10.17.8). |
| EIR-SW-02 | The system SHALL interface with the device operating system's background execution framework for Background Synchronization (Section 10.18.11). |
| EIR-SW-03 | The system SHALL interface with the device's file/media picker and sharing frameworks for Upload Audio (Section 10.6.2), Gallery uploads (Section 10.12), and Export sharing (Sections 10.16.10–10.16.11). |
| EIR-SW-04 | The system SHALL interface with Google's identity platform for Google Sign-In (Section 10.1.3). |

## 12.4 Communication Interface

| ID | Requirement |
|---|---|
| EIR-COMM-01 | All client-backend communication SHALL occur over HTTPS, consistent with Security Requirements (Section 14.4). |
| EIR-COMM-02 | The system SHALL communicate with an SMS gateway service for Phone OTP delivery (Section 10.1.4). |
| EIR-COMM-03 | The system SHALL communicate with an email delivery service for Registration verification, Password Reset, and Family Sharing invitations (Sections 10.1.1, 10.1.5, 10.20.1–10.20.3). |
| EIR-COMM-04 | The system SHALL communicate with a push notification gateway for cross-device Push Notification delivery (Section 10.17.7). |

## 12.5 API Interface

| ID | Requirement |
|---|---|
| EIR-API-01 | The backend SHALL expose a documented, versioned API (Section 11.4.3) providing all operations required by the client application's functional modules (Section 10). |
| EIR-API-02 | The API SHALL enforce authentication (Section 14.1) and Role-Based Permissions (Section 10.20.4) on every endpoint accessing baby profile data. |
| EIR-API-03 | The API SHALL provide dedicated endpoints for AI inference orchestration (Cry Analyzer, AI Assistant), abstracting the underlying AI/ML model-serving environment from the client. |
| EIR-API-04 | The API SHALL support the data operations required for Offline Synchronization (Section 10.18), including batched/queued change submission and conflict-aware reconciliation responses. |

## 12.6 Firebase Integration

| ID | Requirement |
|---|---|
| EIR-FB-01 | The system SHALL integrate with Firebase (or an equivalent managed backend service platform, per Section 17 System Constraints) for authentication support, Push Notification delivery, and/or real-time data synchronization signaling, as applicable to the chosen architecture. |
| EIR-FB-02 | Firebase integration, where used for authentication, SHALL operate as a supporting identity provider layer beneath the application's own user account model (Section 10.1), not as a replacement for the application's Role-Based Access Control (Section 10.20.4). |

## 12.7 Cloudinary Integration

| ID | Requirement |
|---|---|
| EIR-CLD-01 | The system SHALL integrate with Cloudinary (or an equivalent managed media storage/delivery platform) for Gallery Cloud Backup (Section 10.12.7), including photo/video storage, thumbnail generation, and delivery. |
| EIR-CLD-02 | Media Cloud Backup integration SHALL support the format and size constraints defined in Sections 10.12.1–10.12.2 (VR-GAL-PH-01, VR-GAL-VID-01). |

## 12.8 Microphone

| ID | Requirement |
|---|---|
| EIR-MIC-01 | The system SHALL request microphone access permission using the platform's standard permission request flow, with a clear, accessible explanation of purpose, consistent with Section 10.6.1. |
| EIR-MIC-02 | The system SHALL only access the microphone during an active, user-initiated Live Recording session (Section 10.6.1), never in the background without explicit user action. |

## 12.9 Camera

| ID | Requirement |
|---|---|
| EIR-CAM-01 | The system SHALL request camera access permission using the platform's standard permission request flow, with a clear, accessible explanation of purpose, consistent with Sections 10.11.4–10.11.5 and 10.12.1–10.12.2. |

## 12.10 Gallery (Device Media Library)

| ID | Requirement |
|---|---|
| EIR-GALDEV-01 | The system SHALL request device photo/video library access permission using the platform's standard permission request flow, consistent with Sections 10.6.2 and 10.12.1–10.12.2. |
| EIR-GALDEV-02 | The system SHALL request only the minimum necessary scope of device media library access supported by the platform (e.g., selected-photos access where available), consistent with data minimization principles (Section 14.7). |

## 12.11 Notification Services

| ID | Requirement |
|---|---|
| EIR-NOTIFSVC-01 | The system SHALL interface with the platform's push notification service (e.g., the platform-native push gateway underlying Firebase Cloud Messaging or equivalent) for Push Notifications (Section 10.17.7). |
| EIR-NOTIFSVC-02 | The system SHALL interface with the platform's local notification scheduling APIs for Local Notifications (Section 10.17.8), ensuring offline-independent delivery. |

---

# 13. Database Requirements

## 13.1 PostgreSQL (Cloud Structured Data Store)

| ID | Requirement |
|---|---|
| DB-PG-01 | The system SHALL use PostgreSQL (or a compatible managed relational database service) as the primary cloud structured data store, persisting all module data defined in Section 10 (excluding local-only offline cache state). |
| DB-PG-02 | The cloud database schema SHALL be structurally aligned with the local SQLite schema (Section 13.2) to minimize Synchronization (Section 10.18) complexity, consistent with Section 10.18.2. |
| DB-PG-03 | The cloud database SHALL enforce referential integrity (foreign key constraints) between baby profile records and all dependent tracking module records, consistent with Data Separation (VR-DS-01, Section 10.4.4). |

## 13.2 SQLite (Local Structured Data Store)

| ID | Requirement |
|---|---|
| DB-SQL-01 | The system SHALL use SQLite (or an equivalent embedded relational database) as the on-device local structured data store, per Section 10.18.2. |
| DB-SQL-02 | The local database SHALL support the full set of create/read/update/delete operations required by every offline-capable module defined in Section 10, independent of connectivity. |

## 13.3 Offline Database (Behavioral Requirements)

| ID | Requirement |
|---|---|
| DB-OFF-01 | The local database SHALL retain all synchronizable data even across application updates, subject to safe schema migration (VR-SQLITE-01, Section 10.18.2). |
| DB-OFF-02 | The local database SHALL retain a version/last-modified marker on every synchronizable record sufficient to support Conflict Detection (Section 10.18.6). |

## 13.4 Synchronization Strategy

| ID | Requirement |
|---|---|
| DB-SYNC-01 | The database layer SHALL support the Synchronization Queue, Conflict Detection, and Conflict Resolution behaviors defined in Sections 10.18.3, 10.18.6, and 10.18.7 through appropriate schema-level support (change tracking, versioning, soft-delete markers). |
| DB-SYNC-02 | Deletions SHALL be implemented using soft-delete markers at the database layer (rather than immediate hard deletion) for a defined retention window, consistent with the recoverable-deletion patterns established for Gallery (Section 10.12.9) and Cry History (Section 10.6.14). |

## 13.5 Entity Relationships (High-Level)

| Entity | Key Relationships |
|---|---|
| User Account | 1-to-1 with Parent Profile; many-to-many with Baby Profile (via Family Sharing role assignment, Section 10.20) |
| Baby Profile | 1-to-many with Feeding, Sleep, Diaper, Cry Prediction History, Vaccination Schedule, Milestone, Growth Record, Gallery Media entries |
| Baby Profile | many-to-1 (optional) Multiple-Birth-Group reference (Section 10.4.1), for contextual grouping only, not data merging |
| Vaccination Schedule Entry | 1-to-1 (optional) Appointment; many-to-1 Doctor/Hospital reference |
| Milestone Entry | 1-to-many Photos/Videos (shared with Gallery Media) |
| Family Sharing Membership | many-to-1 User Account; many-to-1 Baby Profile; carries assigned Role-Based Permission level (Section 10.20.4) |

*Note: This entity relationship summary is provided at a conceptual level appropriate to a requirements specification. Full schema definition (tables, columns, data types, constraints) is a Database Schema Design Document deliverable, identified in Section 5.3, and is outside the scope of this document.*

## 13.6 Data Retention

| ID | Requirement |
|---|---|
| DB-RET-01 | Tracking module data (Feeding, Sleep, Diaper, Cry History, Vaccination, Milestones, Growth, Gallery) SHALL be retained indefinitely by default, consistent with the long-term baby growth record objective (Section 2.3), unless explicitly deleted by an authorized user. |
| DB-RET-02 | Soft-deleted records (Section 13.4) SHALL be permanently purged after their defined retention window (e.g., 30 days for Gallery, per Section 10.12.9), consistent with data minimization principles. |
| DB-RET-03 | Upon Account Deletion (Section 10.21.10), data SHALL be handled per VR-ACCTMGT-02, purging exclusively-owned data while preserving shared baby profile data still associated with a remaining Full Access holder. |

## 13.7 Backup Strategy

| ID | Requirement |
|---|---|
| DB-BAK-01 | The cloud database SHALL be backed up automatically on a regular schedule, consistent with the Recovery Point Objective defined in NFR-REL-07 (Section 11.2.4). |
| DB-BAK-02 | Database backups SHALL be encrypted at rest, consistent with Section 14.6. |
| DB-BAK-03 | Backup restoration procedures SHALL be periodically tested to verify recoverability. |

## 13.8 Indexes

| ID | Requirement |
|---|---|
| DB-IDX-01 | The database SHALL maintain indexes on all foreign key columns (e.g., baby_profile_id) used to scope queries per Data Separation (Section 10.4.4), to support the query performance targets in Section 11.1.4. |
| DB-IDX-02 | The database SHALL maintain indexes on timestamp columns used for chronological History views (Sections 10.6.12, 10.7.9, 10.8.6, 10.9.8, 10.10.10, 10.11.8, 10.14.6) and Daily/Weekly/Monthly Statistics aggregation. |
| DB-IDX-03 | The database SHALL maintain text-search-supporting indexes for Search functionality (Section 10.19) across notes, captions, and relevant structured fields. |

## 13.9 Transactions

| ID | Requirement |
|---|---|
| DB-TXN-01 | Multi-step write operations (e.g., Twin Baby Registration creating multiple linked profiles, Section 10.4.2; marking a Vaccination Completed while updating Progress Tracking, Section 10.10.11) SHALL be executed within a single atomic database transaction. |
| DB-TXN-02 | The database layer SHALL roll back the entire transaction on partial failure, consistent with NFR-REL-05 (Section 11.2.3). |

## 13.10 Audit Logs

| ID | Requirement |
|---|---|
| DB-AUDIT-01 | The system SHALL maintain an audit log of security-relevant and data-sensitive actions, including: authentication events (Section 10.1), Role-Based Permission changes (Section 10.20.4), Member Removal (Section 10.20.8), Account Deletion (Section 10.21.10), and deletion of Cry History or Gallery media (Sections 10.6.14, 10.12.9). |
| DB-AUDIT-02 | Audit log entries SHALL record the acting user, timestamp, action type, and affected record identifier, and SHALL be immutable (append-only) from within the application. |
| DB-AUDIT-03 | Audit logs SHALL be retained for a defined minimum period sufficient to support security investigation and compliance review (Section 14.9). |

---

# 14. Security Requirements

## 14.1 JWT Authentication

| ID | Requirement |
|---|---|
| SEC-JWT-01 | The system SHALL issue a JSON Web Token (JWT), or equivalent signed token, upon successful authentication (Sections 10.1.1–10.1.4), used to authorize all subsequent API requests. |
| SEC-JWT-02 | JWTs SHALL have a defined, limited expiry, with refresh handled per Session Management (Section 10.1.6). |
| SEC-JWT-03 | JWTs SHALL be signed using a strong, industry-standard algorithm and SHALL NOT embed sensitive personal data (e.g., password, medical information) in the token payload. |

## 14.2 Password Hashing

| ID | Requirement |
|---|---|
| SEC-HASH-01 | User passwords SHALL never be stored in plain text; they SHALL be hashed using a strong, industry-standard, salted hashing algorithm (e.g., bcrypt or Argon2) before persistence. |
| SEC-HASH-02 | Password comparison during Login (Section 10.1.2) SHALL be performed using constant-time comparison against the stored hash. |

## 14.3 Role-Based Access Control

| ID | Requirement |
|---|---|
| SEC-RBAC-01 | The system SHALL enforce Role-Based Permissions (Section 10.20.4) at the API/data access layer on every request, independent of client-side UI restrictions, consistent with VR-RBAC-01. |
| SEC-RBAC-02 | The system SHALL default newly registered baby profiles' creating user to Full Access (Section 10.20.7) and all subsequently invited users to the explicitly assigned, non-default-elevated permission level. |

## 14.4 HTTPS

| ID | Requirement |
|---|---|
| SEC-HTTPS-01 | All client-backend communication SHALL be encrypted in transit using HTTPS (TLS 1.2 or higher), consistent with EIR-COMM-01. |
| SEC-HTTPS-02 | The system SHALL reject or upgrade any attempted plain HTTP connection to the backend API. |

## 14.5 Encrypted SQLite

| ID | Requirement |
|---|---|
| SEC-SQLENC-01 | The local SQLite database (Section 13.2) SHALL be encrypted at rest on-device, using platform-appropriate encryption (e.g., SQLCipher or equivalent), to protect data in the event of device loss or theft. |
| SEC-SQLENC-02 | The local database encryption key SHALL be derived from or protected by platform-provided secure storage (e.g., Android Keystore, iOS Keychain), not hardcoded or stored in plain text. |

## 14.6 Encrypted API Communication

| ID | Requirement |
|---|---|
| SEC-APIENC-01 | All data transmitted between client and backend, and between backend and any third-party integration (Firebase, Cloudinary, SMS/email gateways), SHALL be encrypted in transit, consistent with Section 14.4. |
| SEC-APIENC-02 | All data at rest in the cloud database and cloud media storage SHALL be encrypted, consistent with DB-BAK-02. |

## 14.7 Data Privacy

| ID | Requirement |
|---|---|
| SEC-PRIV-01 | The system SHALL collect only the data necessary to provide its defined functionality (data minimization), consistent with EIR-GALDEV-02. |
| SEC-PRIV-02 | The system SHALL provide the Privacy Settings controls defined in Section 10.21.5, allowing users to control optional data-use/personalization behaviors. |
| SEC-PRIV-03 | Personal and medical data (Sections 10.3.3, 10.13.3) SHALL be accessible only to users with appropriate Role-Based Access (Section 10.20) for the relevant baby profile. |

## 14.8 User Consent

| ID | Requirement |
|---|---|
| SEC-CONSENT-01 | The system SHALL require explicit acceptance of Terms & Privacy Policy during Registration (VR-REG-06, Section 10.1.1) before an account is created. |
| SEC-CONSENT-02 | The system SHALL obtain explicit, purpose-specific permission consent (per platform convention) before accessing microphone, camera, media library, or notification capabilities (Sections 12.8–12.11). |
| SEC-CONSENT-03 | The system SHALL allow users to withdraw optional data-use consent at any time via Privacy Settings (Section 10.21.5), with immediate effect. |

## 14.9 GDPR Readiness

| ID | Requirement |
|---|---|
| SEC-GDPR-01 | The system SHALL support a user's right to access their data via Data Export (Sections 10.16.10–10.16.11, 10.21.9). |
| SEC-GDPR-02 | The system SHALL support a user's right to erasure via Account Deletion (Section 10.21.10), subject to the shared-profile safeguards defined in VR-ACCTMGT-02. |
| SEC-GDPR-03 | The system SHALL maintain records of consent and data-processing purposes sufficient to demonstrate GDPR-aligned accountability, in preparation for operation in applicable jurisdictions. |

## 14.10 Input Validation

| ID | Requirement |
|---|---|
| SEC-INPUT-01 | The system SHALL validate all user input against the Validation Rules defined per module in Section 10, both client-side (for immediate feedback) and server-side (as the authoritative check), never trusting client-side validation alone. |
| SEC-INPUT-02 | The system SHALL reject and safely handle malformed, oversized, or unexpected input at the API layer without exposing internal error detail to the client. |

## 14.11 SQL Injection Prevention

| ID | Requirement |
|---|---|
| SEC-SQLI-01 | The system SHALL use parameterized queries or a vetted Object-Relational Mapping (ORM) layer for all database interactions, never constructing SQL queries via direct string concatenation of user input. |
| SEC-SQLI-02 | The system SHALL apply the same parameterized-query discipline to both the cloud (PostgreSQL) and local (SQLite) data access layers. |

## 14.12 Cross-Site Scripting Prevention

| ID | Requirement |
|---|---|
| SEC-XSS-01 | Any web-facing surface (e.g., the optional web companion interface, Section 11.6.4, or any web-rendered content within the mobile application) SHALL sanitize and appropriately encode all user-generated content (notes, captions, chat messages) before rendering, to prevent script injection. |
| SEC-XSS-02 | The system SHALL apply a Content Security Policy (or equivalent control) on any web-facing surface. |

## 14.13 Secure File Upload

| ID | Requirement |
|---|---|
| SEC-UPLOAD-01 | The system SHALL validate uploaded file type, size, and content against the constraints defined per module (e.g., VR-CRYUP-01–02, VR-GAL-PH-01, VR-GAL-VID-01) on the server side, not solely relying on client-side checks. |
| SEC-UPLOAD-02 | The system SHALL scan or otherwise validate uploaded media/audio files for malformed or malicious content before processing or storage. |
| SEC-UPLOAD-03 | Uploaded files SHALL be stored using generated, non-guessable identifiers, not user-controllable file paths or names, to prevent path traversal or overwrite attacks. |

## 14.14 Session Management (Security Dimension)

| ID | Requirement |
|---|---|
| SEC-SESS-01 | The system SHALL enforce the session expiry, refresh, and offline grace-period rules defined in Section 10.1.6 (VR-SESS-01–03) as security controls limiting the window of exposure from a compromised or lost device. |
| SEC-SESS-02 | The system SHALL invalidate all active sessions for an account upon password change (Section 10.21.6) or detected suspicious activity. |
| SEC-SESS-03 | The system SHALL support remote session/device review and termination, per Section 10.21.6. |

## 14.15 API Security

| ID | Requirement |
|---|---|
| SEC-API-01 | The API SHALL apply rate limiting to authentication endpoints (Login, OTP request, Password Reset) to mitigate brute-force and abuse, consistent with VR-OTP-04 and the login-throttling behavior in Section 10.1.2. |
| SEC-API-02 | The API SHALL apply rate limiting and quota controls to AI inference endpoints (Cry Analyzer, AI Assistant) to prevent abuse and manage cost/resource consumption. |
| SEC-API-03 | The API SHALL validate the requesting user's authentication token and Role-Based Permission on every request, per SEC-RBAC-01, with no endpoint exempted other than explicitly public endpoints (e.g., Registration, Login). |
| SEC-API-04 | The API SHALL log security-relevant request metadata (Section 13.10) without logging full sensitive payloads (e.g., raw passwords) under any circumstance. |

---

# 15. Accessibility Requirements

## 15.1 Purpose and Guiding Principle

Accessibility is a foundational, non-negotiable design pillar of LullaByte, not a supplementary feature. As established in Sections 1.5, 2.3, and 9.2.3, the application is specially designed to be usable by deaf and hard-of-hearing parents as a primary user group. Every requirement in this section applies application-wide, across all modules defined in Section 10, and is informed by general alignment with WCAG 2.1 principles (Section 5.1).

## 15.2 Visual Notifications

| ID | Requirement |
|---|---|
| ACC-VIS-01 | Every notification and alert generated by the Notification System (Section 10.17) SHALL have a corresponding in-application visual representation (banner, badge, or screen state), and SHALL NOT rely on an audible tone as the sole delivery mechanism. |
| ACC-VIS-02 | Cry Analyzer results (Section 10.6.9–10.6.11) SHALL be communicated primarily through visual means (text, color, probability bars), with audio playback (Section 10.6.13) available as a supplementary, opt-in action rather than the primary output. |

## 15.3 Vibration Alerts

| ID | Requirement |
|---|---|
| ACC-VIB-01 | The system SHALL support configurable vibration/haptic alerts for all critical notification types (Vaccination, Missed Vaccination, Medication, and, where applicable, Cry Analyzer completion), per Section 10.21.7. |
| ACC-VIB-02 | Vibration patterns SHOULD be distinguishable by intensity/pattern for differing urgency levels (e.g., a distinct pattern for Missed Vaccination versus Daily Encouragement), where supported by the device platform. |

## 15.4 Large Buttons

| ID | Requirement |
|---|---|
| ACC-BTN-01 | All primary interactive controls (buttons, tap targets) SHALL meet or exceed platform-recommended minimum touch target sizes (e.g., 44x44pt / 48x48dp), consistent with one-handed, time-pressured use patterns identified in Section 9.2.1. |
| ACC-BTN-02 | Quick Action controls (Section 10.5.3) SHALL use enlarged, high-visibility touch targets given their high-frequency use context. |

## 15.5 Large Fonts

| ID | Requirement |
|---|---|
| ACC-FONT-01 | The system SHALL support user-adjustable font scaling (Section 10.21.7) across all interface text, up to a defined maximum scale, without breaking layout (consistent with NFR-USE-09). |
| ACC-FONT-02 | The system SHALL respect the device operating system's system-wide font scale/accessibility text size setting by default, in addition to its own in-app font scaling control. |

## 15.6 Color Indicators

| ID | Requirement |
|---|---|
| ACC-COLOR-01 | Color-coded status indicators (e.g., Confidence Score bands per Section 10.6.9, Missed Vaccination alerts per Section 10.10.5) SHALL always be paired with a non-color differentiator (icon, label, or pattern), consistent with VR-DVIZ-01 (Section 10.16.12). |
| ACC-COLOR-02 | The color palette used for status/severity indication SHALL maintain sufficient contrast and distinguishability for users with common forms of color vision deficiency. |

## 15.7 Simple Navigation

| ID | Requirement |
|---|---|
| ACC-NAV-01 | Navigation SHALL follow the minimal-text-complexity, icon-driven design principle established in Section 9.6, consistent with NFR-USE-01 and VR-NAV-01. |
| ACC-NAV-02 | The system SHALL avoid deeply nested navigation hierarchies; core daily-use modules SHALL remain reachable without requiring the user to recall non-obvious navigation paths. |

## 15.8 Readable Icons

| ID | Requirement |
|---|---|
| ACC-ICON-01 | Icons used throughout the application SHALL be drawn from a consistent, universally recognizable icon set, avoiding ambiguous or culturally specific symbolism. |
| ACC-ICON-02 | Every icon-only interactive control SHALL provide an accessible text label (visible or via screen-reader label per Section 15.9), never conveying meaning through icon shape alone. |

## 15.9 Screen Reader Compatibility

| ID | Requirement |
|---|---|
| ACC-SR-01 | All interactive elements and meaningful content SHALL expose appropriate accessibility labels/roles compatible with platform screen readers (e.g., VoiceOver, TalkBack), supporting users with co-occurring visual accessibility needs. |
| ACC-SR-02 | Dynamic content updates (e.g., a completed AI Prediction result, Section 10.6.8) SHALL be announced appropriately to screen reader users when they occur. |

## 15.10 High Contrast Mode

| ID | Requirement |
|---|---|
| ACC-HC-01 | The system SHALL provide a High Contrast display mode, in addition to standard Light/Dark themes (Section 10.21.2), maximizing text and interactive-element contrast against backgrounds. |
| ACC-HC-02 | High Contrast Mode SHALL apply consistently across all screens and data visualizations (Section 10.16.12), with no exempted areas. |

## 15.11 Accessibility Settings

| ID | Requirement |
|---|---|
| ACC-SET-01 | All accessibility controls described in this section (Visual Notification emphasis, Vibration patterns, Font scaling, Color/High Contrast mode) SHALL be configurable from the single Accessibility Settings screen defined in Section 10.21.7. |
| ACC-SET-02 | The system SHALL pre-populate accessibility defaults based on the accessibility preference indicated during Parent Registration (Section 10.2), consistent with Section 10.21.7, while remaining fully adjustable at any time thereafter. |

---

# 16. Future Scope

## 16.1 Purpose

This section identifies capabilities deliberately excluded from the current functional baseline (Section 3.3) but recognized as valuable directions for the ongoing evolution of LullaByte. These items are documented to demonstrate architectural forethought and to guide long-term product roadmap planning; none are functional requirements of the current release.

## 16.2 Hardware and IoT Integration

| Future Capability | Description |
|---|---|
| Wearable Devices | Integration with infant or parent wearables (e.g., smartwatches) to passively capture sleep and activity signals, reducing manual logging effort. |
| Smart Cradle Integration | Integration with connected smart cradles capable of automated soothing responses triggered by Cry Analyzer results. |
| Baby Monitor Integration | Integration with connected baby monitor hardware, enabling automatic audio capture for Cry Analyzer submission without manual recording. |
| IoT Sensors (General) | A general integration framework for connected nursery sensors (e.g., environmental sensors) feeding into the Dashboard and Reports modules. |
| Temperature Sensors | Integration with connected thermometers/temperature sensors, enabling automated logging of baby temperature readings alongside Medical Information (Section 10.13.3). |
| Heart Rate Sensors | Integration with connected heart-rate monitoring wearables, subject to appropriate medical-device regulatory consideration before any health-metric interpretation is offered. |

## 16.3 Healthcare System Integration

| Future Capability | Description |
|---|---|
| Hospital Integration | Direct integration with hospital systems to support postnatal care continuity, aligned with the "Hospitals" future user category identified in Section 9.4. |
| Electronic Health Records (EHR) | Structured integration with EHR systems, enabling Growth, Vaccination, and Milestone data (Sections 10.10, 10.11, 10.14) to be shared directly with clinical systems, subject to appropriate healthcare data interoperability standards. |
| Doctor Portal | A dedicated, web-based portal experience for the Pediatrician persona (Section 9.3.1), extending beyond the current in-app Invite Doctors capability (Section 10.20.3) with a purpose-built clinical review interface. |

## 16.4 AI and Machine Learning Improvements

| Future Capability | Description |
|---|---|
| Machine Learning Improvements | Ongoing refinement of the Cry Analyzer and AI Assistant models (Sections 10.6, 10.15) using expanded training data and improved model architectures to increase prediction accuracy and Confidence Score reliability. |
| Cry Dataset Expansion | Expansion of the underlying cry classification dataset (Section 5.2) beyond the current category set (Section 4.3), potentially including additional cry categories and greater demographic/environmental diversity. |
| Predictive Analytics | Extension of the Reports and Analytics module (Section 10.16) to provide predictive, forward-looking insights (e.g., anticipated next sleep window with greater precision, feeding pattern forecasting), building on the existing trend-analysis foundation. |

## 16.5 Platform and Reach Expansion

| Future Capability | Description |
|---|---|
| Multi-Language Support | Expansion of the Language Settings capability (Section 10.21.3) to a broader set of supported languages, extending the currently defined officially supported language set. |
| Apple Watch | A companion Apple Watch application surfacing Quick Actions (Section 10.5.3) and critical Notifications (Section 10.17) for rapid, glanceable interaction. |
| Wear OS | A companion Wear OS application providing equivalent functionality to the Apple Watch companion, for Android-based smartwatch users. |
| Smart Home Integration | Integration with smart home ecosystems (e.g., voice assistants, connected lighting) to support ambient, hands-free notification delivery, with continued adherence to the visual/haptic-first accessibility principle (Section 15) for deaf users. |

---

# 17. Conclusion

## 17.1 Project Vision

LullaByte represents a deliberate convergence of artificial intelligence and accessibility-first design in service of one of the most emotionally and physically demanding periods in family life: the newborn stage. Rather than treating cry interpretation as an isolated novelty feature, this specification has defined LullaByte as a complete newborn care management platform — one in which AI-assisted cry analysis, feeding, sleep, diaper, health, growth, and developmental tracking operate as a single, coherent system, usable equally well offline in a quiet nursery at 3 a.m. or synchronized across a shared family account spanning multiple caregivers.

## 17.2 Objectives Realized Through This Specification

The functional and non-functional requirements defined throughout this document collectively operationalize the objectives established in Section 2: enabling deaf parents to understand their baby's needs without relying on sound (Section 15); supporting first-time parents through structured, low-friction tracking and AI-assisted guidance (Sections 10.5, 10.15); consolidating fragmented newborn care record-keeping into a single, longitudinally durable platform (Sections 10.6–10.14); and ensuring the application remains fully usable regardless of connectivity, through comprehensive Offline Synchronization (Section 10.18).

## 17.3 Expected Benefits

For the families who use it, LullaByte is expected to reduce the cognitive and emotional burden of newborn care by replacing scattered paper logs, memory-dependent tracking, and uncertainty about a crying baby's needs with a single, accessible, always-available companion. For deaf parents specifically, the application is expected to close a meaningful accessibility gap left unaddressed by conventional, hearing-oriented baby monitoring products. For families with twins or multiple children, the platform's explicit multi-baby and data-separation architecture (Section 10.4) is expected to prevent the record-keeping confusion common to ad hoc tracking methods.

## 17.4 Future Expansion

The architecture and requirements defined in this specification have been deliberately structured — through modular design (Section 11.4.1), a synchronization-ready database strategy (Section 13), and a scalable backend approach (Section 11.5) — to accommodate the Future Scope identified in Section 16 without requiring foundational redesign. This positions LullaByte to grow from an initial mobile release into a broader ecosystem spanning wearables, smart nursery hardware, and healthcare system integration, as adoption and validation warrant.

## 17.5 Impact on Parents

By combining AI-assisted interpretation with comprehensive, accessible care tracking, LullaByte is positioned to directly support the well-being of the parents and caregivers who use it — not only through practical time savings, but through the reassurance and confidence that comes from having a clear, data-informed picture of a baby's patterns and needs, always paired with clear, non-diagnostic framing and a consistent recommendation to seek professional pediatric care when appropriate (Sections 10.15.9, 15).

## 17.6 Impact on Healthcare

Beyond the immediate household, the longitudinal, structured records LullaByte enables — growth history, vaccination compliance, developmental milestones, and exportable reports (Sections 10.14, 10.16) — are positioned to support more informed, efficient pediatric consultations, and, as identified in the Future Scope (Section 16.3), lay the groundwork for deeper integration with hospitals, clinics, and childcare centers as the product matures beyond its initial release.

## 17.7 Closing Statement

This Software Requirements Specification has defined, in full, the functional and non-functional foundation required to design, build, test, and evaluate LullaByte as a production-ready, accessibility-first, AI-powered newborn care platform. It is intended to serve as the authoritative reference throughout the system's development lifecycle and as a durable foundation for its continued growth.

---

*This is the end of the Software Requirements Specification for LullaByte — AI Powered Newborn Care Assistant.*
