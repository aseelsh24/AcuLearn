# Content Import Schemas: JSON & CSV

## Purpose

This document defines the **exact schemas** that content authors (clinicians, educators, non-programmers) must follow when creating question banks for AcuLearn.

These schemas support all 4 assessment modes:
1. **MCQ** (Multiple Choice Question)
2. **Written** (Short Answer / Free Text)
3. **Oral** (Viva / Self-Assessment)
4. **OSCE** (Clinical Station / Skills Assessment)

---

## JSON Schema

### Overview

Questions are stored as a **JSON array** of question objects. Each question object contains all fields needed for rendering, scoring, and filtering.

### File Format

- **Encoding:** UTF-8
- **File Extension:** `.json`
- **Structure:** Root-level JSON array `[ {...}, {...}, ... ]`

### Complete JSON Schema

```json
[
  {
    "id": <integer | string>,
    "text": <string>,
    "mode": <"mcq" | "written" | "oral" | "osce">,
    "options": <array of strings | null>,
    "correctIndex": <integer | null>,
    "expectedAnswer": <string | null>,
    "explanation": <string | null>,
    "specialtyModule": <string>,
    "academicLevel": <"undergrad" | "postgrad">,
    "blockOrSemester": <string>
  }
]
```

---

## Field Definitions

### 1. `id` (Required)
- **Type:** Integer or String
- **Description:** Unique identifier for the question
- **Rules:**
  - Must be unique across the entire question bank
  - Can be numeric (e.g., `101`) or string (e.g., `"neo-001"`)
- **Examples:** `101`, `"mcq_neo_hypothermia"`, `1001`

---

### 2. `text` (Required)
- **Type:** String
- **Description:** The question stem, case vignette, or scenario
- **Rules:**
  - Cannot be empty
  - Can include clinical details, vital signs, lab values
  - Use clear, professional medical language
- **Examples:**
  ```json
  "text": "A newborn is hypothermic at 35.0°C. What is the FIRST priority?"
  ```
  ```json
  "text": "You are on rounds and asked: Outline immediate steps in suspected neonatal sepsis."
  ```

---

### 3. `mode` (Required)
- **Type:** String (enum)
- **Description:** Assessment type / rendering mode
- **Allowed Values:** `"mcq"`, `"written"`, `"oral"`, `"osce"`
- **Rules:**
  - **MUST** be one of the 4 allowed values (case-sensitive, lowercase)
  - Determines how the UI renders the question
- **Examples:**
  ```json
  "mode": "mcq"
  ```
  ```json
  "mode": "osce"
  ```

---

### 4. `options` (Conditional)
- **Type:** Array of Strings **OR** `null`
- **Description:** Answer choices for MCQ questions
- **Rules:**
  - **Required for `mode: "mcq"`** → Must be an array with 3–5 strings
  - **Must be `null` for other modes** (`"written"`, `"oral"`, `"osce"`)
  - Each option should be a distinct, plausible answer
- **Examples:**
  ```json
  "options": [
    "Start broad-spectrum antibiotics",
    "Immediate warming / incubator / skin-to-skin",
    "Give paracetamol",
    "No action, this is normal"
  ]
  ```
  ```json
  "options": null   // For written/oral/OSCE modes
  ```

---

### 5. `correctIndex` (Conditional)
- **Type:** Integer **OR** `null`
- **Description:** Zero-based index of the correct answer in `options` array
- **Rules:**
  - **Required for `mode: "mcq"`** → Must be a valid index (0 to `options.length - 1`)
  - **Must be `null` for other modes**
  - Zero-indexed (first option = 0, second = 1, etc.)
- **Examples:**
  ```json
  "correctIndex": 1   // Second option is correct
  ```
  ```json
  "correctIndex": null   // For written/oral/OSCE
  ```

---

### 6. `expectedAnswer` (Conditional)
- **Type:** String **OR** `null`
- **Description:** Model answer, key points, or checklist
- **Rules:**
  - **Required for `mode: "written" | "oral" | "osce"`** → Provide expected response
  - **Must be `null` for `mode: "mcq"`** (use `explanation` instead)
  - For **written:** Model short answer or key phrases
  - For **oral:** High-yield talking points (can be a list)
  - For **OSCE:** Required actions / clinical steps
- **Examples:**
  ```json
  "expectedAnswer": "Sepsis work-up: blood culture, CBC, CRP. Start ampicillin + gentamicin. Monitor vitals."
  ```
  ```json
  "expectedAnswer": "Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation."
  ```
  ```json
  "expectedAnswer": null   // For MCQ mode
  ```

---

### 7. `explanation` (Optional but Recommended)
- **Type:** String **OR** `null`
- **Description:** Clinical rationale, guideline reference, teaching point
- **Rules:**
  - Shown to the user after answering (in Review screen)
  - Should explain **why** the correct answer is correct (or what the key learning is)
  - Can include guideline citations (e.g., WHO, AAP, local protocols)
- **Examples:**
  ```json
  "explanation": "35.0°C = hypothermia. Priority is rewarming and thermal protection, not drugs. Per WHO thermal care guidelines."
  ```
  ```json
  "explanation": "These are core first-hour sepsis steps in neonates per most low-resource protocols (e.g., WHO ETAT+)."
  ```

---

### 8. `specialtyModule` (Required)
- **Type:** String
- **Description:** Clinical specialty, topic, or module name
- **Rules:**
  - Used to group questions into modules on the Home screen
  - Should be consistent across questions in the same module
  - Examples: `"Neonatology"`, `"ICU / Sepsis"`, `"Pharmacology"`, `"OSCE: Neonatal Resuscitation"`
- **Examples:**
  ```json
  "specialtyModule": "Neonatology"
  ```
  ```json
  "specialtyModule": "Emergency Medicine / Trauma"
  ```

---

### 9. `academicLevel` (Required)
- **Type:** String (enum)
- **Description:** Target training level
- **Allowed Values:** `"undergrad"` **OR** `"postgrad"`
- **Rules:**
  - **MUST** be exactly `"undergrad"` or `"postgrad"` (case-sensitive, lowercase)
  - Used to filter questions by track (Track Selection screen)
  - Determines difficulty and clinical depth
- **Examples:**
  ```json
  "academicLevel": "undergrad"
  ```
  ```json
  "academicLevel": "postgrad"
  ```

---

### 10. `blockOrSemester` (Required)
- **Type:** String
- **Description:** Academic block, semester, rotation, or curriculum mapping
- **Rules:**
  - Allows programs to map content to their own curriculum structure
  - Can be year-based (e.g., `"Year 4 Pediatrics Block"`) or rotation-based (e.g., `"NICU Rotation"`)
  - Flexible format (institutions define their own structure)
- **Examples:**
  ```json
  "blockOrSemester": "Year 4 Pediatrics Block"
  ```
  ```json
  "blockOrSemester": "NICU Rotation"
  ```
  ```json
  "blockOrSemester": "Internship ED Month"
  ```

---

## Complete JSON Examples

### Example 1: MCQ Question (Undergraduate)

```json
{
  "id": 101,
  "text": "A newborn is hypothermic at 35.0°C. What is the FIRST priority?",
  "mode": "mcq",
  "options": [
    "Start broad-spectrum antibiotics",
    "Immediate warming / incubator / skin-to-skin",
    "Give paracetamol",
    "No action, this is normal"
  ],
  "correctIndex": 1,
  "expectedAnswer": null,
  "explanation": "35.0°C = hypothermia. Priority is rewarming and thermal protection, not drugs. Per WHO thermal care guidelines.",
  "specialtyModule": "Neonatology",
  "academicLevel": "undergrad",
  "blockOrSemester": "Year 4 Pediatrics Block"
}
```

---

### Example 2: Oral/Viva Question (Postgraduate)

```json
{
  "id": 202,
  "text": "You are on rounds and asked: Outline immediate steps in suspected neonatal sepsis.",
  "mode": "oral",
  "options": null,
  "correctIndex": null,
  "expectedAnswer": "Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation.",
  "explanation": "These are core first-hour sepsis steps in neonates per most low-resource protocols (e.g., WHO ETAT+).",
  "specialtyModule": "Neonatology / Sepsis",
  "academicLevel": "postgrad",
  "blockOrSemester": "NICU Rotation"
}
```

---

### Example 3: Written Question (Undergraduate)

```json
{
  "id": 303,
  "text": "List 3 common causes of neonatal hypoglycemia.",
  "mode": "written",
  "options": null,
  "correctIndex": null,
  "expectedAnswer": "1. Prematurity / SGA, 2. Infant of diabetic mother, 3. Sepsis / infection",
  "explanation": "These are the most common causes in undergrad curricula. Additional causes include inborn errors of metabolism, hyperinsulinism.",
  "specialtyModule": "Neonatology",
  "academicLevel": "undergrad",
  "blockOrSemester": "Year 4 Pediatrics Block"
}
```

---

### Example 4: OSCE Station (Postgraduate)

```json
{
  "id": 404,
  "text": "Neonatal Resuscitation Station: A term newborn is delivered and is not breathing. Outline your immediate actions.",
  "mode": "osce",
  "options": null,
  "correctIndex": null,
  "expectedAnswer": "Dry and stimulate. Assess breathing. If not breathing: position airway, clear if needed, PPV with bag-mask. Reassess at 30 seconds. Check HR. Escalate per NRP algorithm.",
  "explanation": "This follows NRP (Neonatal Resuscitation Program) initial steps. Key: PPV is the priority intervention for non-breathing newborn.",
  "specialtyModule": "OSCE: Neonatal Resuscitation",
  "academicLevel": "postgrad",
  "blockOrSemester": "NICU Rotation"
}
```

---

## Full JSON File Example

```json
[
  {
    "id": 101,
    "text": "A newborn is hypothermic at 35.0°C. What is the FIRST priority?",
    "mode": "mcq",
    "options": [
      "Start broad-spectrum antibiotics",
      "Immediate warming / incubator / skin-to-skin",
      "Give paracetamol",
      "No action, this is normal"
    ],
    "correctIndex": 1,
    "expectedAnswer": null,
    "explanation": "35.0°C = hypothermia. Priority is rewarming and thermal protection, not drugs.",
    "specialtyModule": "Neonatology",
    "academicLevel": "undergrad",
    "blockOrSemester": "Year 4 Pediatrics Block"
  },
  {
    "id": 202,
    "text": "You are on rounds and asked: Outline immediate steps in suspected neonatal sepsis.",
    "mode": "oral",
    "options": null,
    "correctIndex": null,
    "expectedAnswer": "Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation.",
    "explanation": "These are core first-hour sepsis steps in neonates per most low-resource protocols.",
    "specialtyModule": "Neonatology / Sepsis",
    "academicLevel": "postgrad",
    "blockOrSemester": "NICU Rotation"
  },
  {
    "id": 303,
    "text": "List 3 common causes of neonatal hypoglycemia.",
    "mode": "written",
    "options": null,
    "correctIndex": null,
    "expectedAnswer": "1. Prematurity / SGA, 2. Infant of diabetic mother, 3. Sepsis / infection",
    "explanation": "These are the most common causes in undergrad curricula.",
    "specialtyModule": "Neonatology",
    "academicLevel": "undergrad",
    "blockOrSemester": "Year 4 Pediatrics Block"
  }
]
```

---

## CSV Schema

### Overview

For educators who prefer spreadsheets, questions can be provided as **CSV files**. Each row is one question.

### File Format

- **Encoding:** UTF-8
- **File Extension:** `.csv`
- **Delimiter:** Comma (`,`)
- **Header Row:** REQUIRED (must match schema)

---

### CSV Column Schema (Header Row)

```
id,text,mode,options,correctIndex,expectedAnswer,explanation,specialtyModule,academicLevel,blockOrSemester
```

**All 10 columns MUST be present in this exact order.**

---

### Column Definitions (CSV)

| Column | Type | Description | Format / Rules |
|--------|------|-------------|----------------|
| `id` | Integer/String | Unique identifier | No commas |
| `text` | String | Question stem | Quoted if contains commas |
| `mode` | Enum | Assessment type | `mcq`, `written`, `oral`, or `osce` |
| `options` | Array/Empty | MCQ choices | `[Option 1;Option 2;Option 3]` (semicolon-separated inside brackets) OR empty |
| `correctIndex` | Integer/Empty | Correct answer index (0-based) | Integer for MCQ, empty for others |
| `expectedAnswer` | String/Empty | Model answer / checklist | Quoted if contains commas, empty for MCQ |
| `explanation` | String/Empty | Clinical rationale | Quoted if contains commas |
| `specialtyModule` | String | Module name | No commas (or quote entire field) |
| `academicLevel` | Enum | Training level | `undergrad` or `postgrad` (exact match) |
| `blockOrSemester` | String | Curriculum mapping | No commas (or quote entire field) |

---

### CSV Formatting Rules

1. **Options for MCQ:**
   - Format: `[Option 1;Option 2;Option 3;Option 4]`
   - Wrap in square brackets `[ ]`
   - Separate options with semicolons `;` (NOT commas)
   - Example: `[Start antibiotics;Warm the baby;Give paracetamol;Do nothing]`

2. **Empty Fields:**
   - Leave cell empty (do NOT use "null" or "N/A")
   - For MCQ: `expectedAnswer` is empty
   - For Written/Oral/OSCE: `options` and `correctIndex` are empty

3. **Text with Commas:**
   - Wrap entire field in double quotes
   - Example: `"A newborn is hypothermic at 35.0°C. Priority?"`

4. **Line Breaks in Text:**
   - Use `\n` or wrap field in quotes and use actual line breaks (depends on CSV parser)

---

## CSV Examples

### Example 1: MCQ Question (Undergraduate)

```csv
id,text,mode,options,correctIndex,expectedAnswer,explanation,specialtyModule,academicLevel,blockOrSemester
101,"A newborn is hypothermic at 35.0°C. What is the FIRST priority?",mcq,"[Start broad-spectrum antibiotics;Immediate warming / incubator / skin-to-skin;Give paracetamol;No action, this is normal]",1,,"35.0°C = hypothermia. Priority is rewarming and thermal protection, not drugs.",Neonatology,undergrad,Year 4 Pediatrics Block
```

---

### Example 2: Oral/Viva Question (Postgraduate)

```csv
id,text,mode,options,correctIndex,expectedAnswer,explanation,specialtyModule,academicLevel,blockOrSemester
202,"You are on rounds and asked: Outline immediate steps in suspected neonatal sepsis.",oral,,,,"Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation.","These are core first-hour sepsis steps in neonates per most low-resource protocols.",Neonatology / Sepsis,postgrad,NICU Rotation
```

---

### Example 3: Written Question (Undergraduate)

```csv
id,text,mode,options,correctIndex,expectedAnswer,explanation,specialtyModule,academicLevel,blockOrSemester
303,"List 3 common causes of neonatal hypoglycemia.",written,,,"1. Prematurity / SGA, 2. Infant of diabetic mother, 3. Sepsis / infection","These are the most common causes in undergrad curricula.",Neonatology,undergrad,Year 4 Pediatrics Block
```

---

### Example 4: OSCE Station (Postgraduate)

```csv
id,text,mode,options,correctIndex,expectedAnswer,explanation,specialtyModule,academicLevel,blockOrSemester
404,"Neonatal Resuscitation Station: A term newborn is delivered and is not breathing. Outline your immediate actions.",osce,,,"Dry and stimulate. Assess breathing. If not breathing: position airway, clear if needed, PPV with bag-mask. Reassess at 30 seconds. Check HR. Escalate per NRP algorithm.","This follows NRP initial steps. Key: PPV is the priority intervention for non-breathing newborn.",OSCE: Neonatal Resuscitation,postgrad,NICU Rotation
```

---

### Full CSV File Example

```csv
id,text,mode,options,correctIndex,expectedAnswer,explanation,specialtyModule,academicLevel,blockOrSemester
101,"A newborn is hypothermic at 35.0°C. What is the FIRST priority?",mcq,"[Start broad-spectrum antibiotics;Immediate warming / incubator / skin-to-skin;Give paracetamol;No action, this is normal]",1,,"35.0°C = hypothermia. Priority is rewarming and thermal protection, not drugs.",Neonatology,undergrad,Year 4 Pediatrics Block
202,"You are on rounds and asked: Outline immediate steps in suspected neonatal sepsis.",oral,,,,"Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation.","These are core first-hour sepsis steps in neonates per most low-resource protocols.",Neonatology / Sepsis,postgrad,NICU Rotation
303,"List 3 common causes of neonatal hypoglycemia.",written,,,"1. Prematurity / SGA, 2. Infant of diabetic mother, 3. Sepsis / infection","These are the most common causes in undergrad curricula.",Neonatology,undergrad,Year 4 Pediatrics Block
404,"Neonatal Resuscitation Station: A term newborn is delivered and is not breathing. Outline your immediate actions.",osce,,,"Dry and stimulate. Assess breathing. If not breathing: position airway, clear if needed, PPV with bag-mask. Reassess at 30 seconds. Check HR. Escalate per NRP algorithm.","This follows NRP initial steps. Key: PPV is the priority intervention for non-breathing newborn.",OSCE: Neonatal Resuscitation,postgrad,NICU Rotation
```

---

## Validation Rules (for Content Authors)

### Required Checks Before Submitting Content

1. **All 10 fields present** (even if empty for some modes)
2. **`mode` is one of:** `mcq`, `written`, `oral`, `osce`
3. **`academicLevel` is one of:** `undergrad`, `postgrad` (exact match, lowercase)
4. **For MCQ mode:**
   - `options` is an array (JSON) or `[...]` format (CSV) with 3–5 choices
   - `correctIndex` is a valid index (0 to options.length - 1)
   - `expectedAnswer` is empty/null
5. **For Written/Oral/OSCE modes:**
   - `options` is null/empty
   - `correctIndex` is null/empty
   - `expectedAnswer` is NOT empty (provide model answer)
6. **No duplicate `id` values**
7. **`specialtyModule` is consistent** (e.g., always "Neonatology", not "Neonatology" vs "Neonat" vs "Neo")

---

## How This Data is Used

### In the App

1. **Track Selection Screen:**
   - Filters questions by `academicLevel` (`"undergrad"` or `"postgrad"`)

2. **Home Screen:**
   - Groups questions by `specialtyModule`
   - Displays available modules as cards/buttons

3. **Quiz Screen:**
   - Renders question based on `mode`:
     - `mcq` → Shows options as tappable buttons
     - `written` → Shows text input field
     - `oral` → Shows prompt + self-score checklist
     - `osce` → Shows scenario + action checklist

4. **Result Screen:**
   - Calculates score (for MCQ)
   - Shows completion summary

5. **Review Screen:**
   - Shows:
     - Original question (`text`)
     - User's answer
     - Correct answer (`correctIndex` for MCQ, `expectedAnswer` for others)
     - Clinical rationale (`explanation`)

---

## Future Enhancements

1. **CSV Import in App:**
   - Future feature: Allow educators to upload CSV files directly in the app
   - App parses CSV and adds questions to local database

2. **Validation Tool:**
   - Standalone CLI tool to validate JSON/CSV before submission
   - Checks schema compliance, duplicate IDs, valid enums

3. **Multi-Language Support:**
   - Add `language` field for Arabic translations
   - Same schema, different text content

---

## Content Author Checklist

- [ ] All 10 required fields present in each question
- [ ] `mode` is exactly one of: `mcq`, `written`, `oral`, `osce`
- [ ] `academicLevel` is exactly `undergrad` or `postgrad`
- [ ] For MCQ: `options` has 3–5 choices, `correctIndex` is valid, `expectedAnswer` is empty
- [ ] For other modes: `options` and `correctIndex` are empty, `expectedAnswer` is filled
- [ ] No duplicate `id` values
- [ ] `specialtyModule` names are consistent across questions in same module
- [ ] `explanation` provided (helps learners understand the answer)
- [ ] Clinical accuracy reviewed by subject matter expert
- [ ] CSV: Options formatted as `[Option1;Option2;Option3]` (semicolon-separated)
- [ ] CSV: Text fields with commas are quoted

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-03  
**Owner:** Lead Engineer + Content Team  
**Status:** Final - Ready for Content Authors
