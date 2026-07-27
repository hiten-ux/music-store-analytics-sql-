# Data Dictionary – Music Store Database

## Overview
This document provides detailed column definitions for all 11 tables in the Music Store database.

---

## Table: `artist`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `artist_id` | INT | NO | Primary key, unique identifier for each artist |
| `artist_name` | VARCHAR(85) | NO | Name of the artist (e.g., AC/DC, Queen) |

**Records:** 275

---

## Table: `album`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `album_id` | INT | NO | Primary key, unique identifier for each album |
| `album_title` | VARCHAR(95) | NO | Title of the album |
| `artist_id` | INT | NO | Foreign key → `artist.artist_id` |

**Records:** 347

---

## Table: `genre`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `genre_id` | INT | NO | Primary key, unique identifier for each genre |
| `genre_name` | VARCHAR(18) | NO | Name of the genre (Rock, Metal, Pop, etc.) |

**Records:** 25

---

## Table: `media_type`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `media_type_id` | INT | NO | Primary key, unique identifier for each media format |
| `media_type_name` | VARCHAR(27) | NO | Format name (MPEG audio file, AAC audio file, etc.) |

**Records:** 5

---

## Table: `track`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `track_id` | INT | NO | Primary key, unique identifier for each track |
| `track_name` | VARCHAR(123) | NO | Name of the track/song |
| `album_id` | INT | NO | Foreign key → `album.album_id` |
| `media_type_id` | INT | NO | Foreign key → `media_type.media_type_id` |
| `genre_id` | INT | NO | Foreign key → `genre.genre_id` |
| `composer` | VARCHAR(188) | YES | Name of the composer(s) |
| `milliseconds` | INT | NO | Duration of the track in milliseconds |
| `bytes` | INT | NO | File size in bytes |
| `unit_price` | DECIMAL(10,2) | NO | Price per track |

**Records:** 3,503

---

## Table: `playlist`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `playlist_id` | INT | NO | Primary key, unique identifier for each playlist |
| `playlist_name` | VARCHAR(26) | NO | Name of the playlist |

**Records:** 18

---

## Table: `playlist_track`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `playlist_id` | INT | NO | Foreign key → `playlist.playlist_id` |
| `track_id` | INT | NO | Foreign key → `track.track_id` |

**Primary Key:** (playlist_id, track_id)

---

## Table: `employee`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `employee_id` | INT | NO | Primary key, unique identifier for each employee |
| `last_name` | VARCHAR(8) | NO | Employee's last name |
| `first_name` | VARCHAR(8) | NO | Employee's first name |
| `title` | VARCHAR(22) | NO | Job title (Sales Support Agent, IT Staff, etc.) |
| `reports_to` | INT | YES | Manager's employee_id → `employee.employee_id` |
| `levels` | VARCHAR(2) | NO | Employee level (L1-L7) |
| `birthdate` | DATE | NO | Date of birth |
| `hire_date` | DATE | NO | Date of hire |
| `address` | VARCHAR(27) | NO | Employee address |
| `city` | VARCHAR(10) | NO | City |
| `state` | VARCHAR(2) | NO | State/Province |
| `country` | VARCHAR(6) | NO | Country |
| `postal_code` | VARCHAR(7) | NO | Postal/ZIP code |
| `phone` | VARCHAR(17) | NO | Phone number |
| `fax` | VARCHAR(17) | NO | Fax number |
| `email` | VARCHAR(27) | NO | Email address |

**Records:** 9

---

## Table: `customer`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `customer_id` | INT | NO | Primary key, unique identifier for each customer |
| `first_name` | VARCHAR(9) | NO | Customer's first name |
| `last_name` | VARCHAR(12) | NO | Customer's last name |
| `company` | VARCHAR(48) | YES | Company name (if applicable) |
| `address` | VARCHAR(40) | NO | Customer address |
| `city` | VARCHAR(19) | NO | City |
| `state` | VARCHAR(6) | YES | State/Province |
| `country` | VARCHAR(14) | NO | Country |
| `postal_code` | VARCHAR(10) | YES | Postal/ZIP code |
| `phone` | VARCHAR(19) | YES | Phone number |
| `fax` | VARCHAR(18) | YES | Fax number |
| `email` | VARCHAR(29) | NO | Email address |
| `support_rep_id` | INT | NO | Foreign key → `employee.employee_id` |

**Records:** 59

---

## Table: `invoice`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `invoice_id` | INT | NO | Primary key, unique identifier for each invoice |
| `customer_id` | INT | NO | Foreign key → `customer.customer_id` |
| `invoice_date` | TIMESTAMP | NO | Date and time of purchase |
| `billing_address` | VARCHAR(40) | NO | Billing address |
| `billing_city` | VARCHAR(19) | NO | Billing city |
| `billing_state` | VARCHAR(6) | YES | Billing state/province |
| `billing_country` | VARCHAR(14) | NO | Billing country |
| `billing_postal_code` | VARCHAR(10) | NO | Billing postal code |
| `total` | DECIMAL(10,2) | NO | Total invoice amount |

**Records:** 614

---

## Table: `invoice_line`
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `invoice_line_id` | INT | NO | Primary key, unique identifier for each line item |
| `invoice_id` | INT | NO | Foreign key → `invoice.invoice_id` |
| `track_id` | INT | NO | Foreign key → `track.track_id` |
| `unit_price` | DECIMAL(10,2) | NO | Price of the track at time of purchase |
| `quantity` | TINYINT | NO | Number of units purchased |

**Records:** 1,000+

---

## 🔗 Foreign Key Relationships

| Table | Foreign Key | References |
|-------|-------------|------------|
| `album` | `artist_id` | `artist.artist_id` |
| `track` | `album_id` | `album.album_id` |
| `track` | `media_type_id` | `media_type.media_type_id` |
| `track` | `genre_id` | `genre.genre_id` |
| `playlist_track` | `playlist_id` | `playlist.playlist_id` |
| `playlist_track` | `track_id` | `track.track_id` |
| `customer` | `support_rep_id` | `employee.employee_id` |
| `invoice` | `customer_id` | `customer.customer_id` |
| `invoice_line` | `invoice_id` | `invoice.invoice_id` |
| `invoice_line` | `track_id` | `track.track_id` |

---

## 📊 Summary Statistics

| Table | Records |
|-------|---------|
| `artist` | 275 |
| `album` | 347 |
| `track` | 3,503 |
| `genre` | 25 |
| `media_type` | 5 |
| `playlist` | 18 |
| `playlist_track` | 500+ |
| `employee` | 9 |
| `customer` | 59 |
| `invoice` | 614 |
| `invoice_line` | 1,000+ |
