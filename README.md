# Health Wallet – Demo Version

A personal health data organizer that helps users track lab results, imaging reports, and bioimpedance exams in one place.
Built with Ruby on Rails as a full-stack solo developer project.

## 🔍 Overview

This is a simplified, demo-friendly version of my original health data platform.
It simulates how a user can upload health documents and get a structured, searchable view of their health data and health timeline.

This project was built to solve a personal frustration: how hard it is to keep track of medical exams and extract insights over time.

## 🧩 Key Features

- 📁 Upload PDF medical reports (e.g. blood tests, bioimpedance, image reports)
- 🧠 AI-assisted text extraction (OCR + heuristic parsing)
- 📊 Visualization of health markers across time
- 🔍 Search and filter biomarkers by organ/system
- 🗃️ Structured models: `Source`, `Measure`, `ImagingReport`, `Human`, `Biomarker`, `Organ`, `BodyPart`

## ✨ What I'm Most Proud Of

- Designing a modular domain model that mirrors human physiology
- Implementing flexible source handling for multiple health data types
- Using Ruby metaprogramming (e.g., polymorphic relationships) to make the system easily extensible
- Organizing the frontend using SUIT CSS + Bootstrap to support mobile-first design

## 📂 Folder Structure

```bash
app/
├── models/
├── controllers/
├── views/
├── assets/stylesheets/components/    # SUIT-based UI
└── services/                         # PDF parsing
docs/
├── llm_notes.md                      # Notes from LLM-assisted development
├── data_model.md                     # Explanation of schema and architecture

```

## 🛠️ Tech Stack

Ruby on Rails 7

PostgreSQL

ActiveStorage (PDF uploads)

ActiveAdmin

StimulusJS

Chart.js

SUIT CSS methodology

Bootstrap 5

## 📸 App Demo (Try It Yourself)
**To see how the data is organized and how users can interact with their data:**

👉 [My real profile](https://smarthealth-prod-a89f7e2c4ece.herokuapp.com/humans/34/)

**To see how the App gets data from the users:**

👉 [Demo Profile](https://smarthealth-prod-a89f7e2c4ece.herokuapp.com/humans/265/)

Upload a sample exam (blood test, imaging report, or bioimpedance PDF)
The system will parse and display structured insights automatically

Want a test file? Let me know — I’ll gladly send one.

## 🚀 Next Steps / If I Had More Time
Add user authentication

Implement longitudinal analytics for health risk tracking

Make the PDF parsing pipeline fully async with Sidekiq
