# repositories

Repository Pattern implementations (SAD Section 6.2) mediating between
`services/` and `database/` — one repository per entity, providing a
consistent CRUD/query interface and centralizing Data Separation (SRS
Section 10.4.4) and Role-Based Access scoping (SRS Section 10.20.4) at a
single point per entity type.
