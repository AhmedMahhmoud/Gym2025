# AI Coding & Collaboration Rules

A concise reference to guide collaborative development, ensuring clean, readable, and maintainable code at every step.

## 1. Engage as a Senior Engineer
- Communicate thoughtfully and strategically, focusing on architecture, scalability, and maintainability.
- Approach discussions and reviews as a peer, offering insights into potential impacts and long-term considerations.

## 2. Code Quality Standards
- **Clean Code & Readability:**
  - Use clear, descriptive names for variables, functions, and classes.
  - Keep methods short (ideally < 20–30 lines) and focused on a single task.
  - Apply consistent formatting: rely on automated formatters (e.g., `dart format`, `prettier`, `black`).
- **Linting & Static Analysis:**
  - Enable and configure linters to enforce style rules and catch common mistakes early.
  - Address all lint warnings; treat critical rules (e.g., null safety, unused imports) as errors in CI.
- **DRY Principles:**
  - Extract duplicated code into shared utilities or services.
  - Avoid copy-paste; centralize logic in one place with clear interfaces.

## 3. Impact Awareness
- Analyze how changes ripple through modules and dependencies.
- Highlight integration points and potential side effects in code reviews and design discussions.
- Use feature toggles or branch flags for high-risk changes.

## 4. Separation & Enhancement
- **Modularity:**
  - Break large files into smaller, purpose-driven modules or packages.
  - Group related functionality together
- **Enhancement:**
  - Refactor code incrementally, improving structure without altering business logic.
  - Leverage design patterns (Factory, Strategy, Observer) when they clarify intent and reduce coupling.

## 5. Performance Focus
- **Efficient Algorithms & Data Structures:**
  - Choose appropriate complexity for operations; avoid O(n²) in hot paths.
  - Cache expensive computations and reuse results when safe.
- **Resource Management:**
  - Close or dispose of resources (streams, controllers, file handles) promptly.
  - Profile and benchmark critical components; eliminate bottlenecks iteratively.

## 6. Summary & Rating
- After delivering code or review feedback, provide a brief summary of changes and their rationale.
- Rate the current code’s efficiency and readability on a simple 
##7. Ui scalability 
- Extract widgets into separated file if they can be used in multiple places
-Check if the app already contains this widget and reuse it or reccomend it if available 
-Use the app custom colors in the colors class and always look in the shared files before creating any ui from scratch
-Always use modern ui and create design that matches the app colors

*Following these principles will help maintain high standards, streamline collaboration, and ensure sustainable code evolution.*