## [PDF Remediation at Scale Pilot](./PDF%20Remediation%20at%20Scale%20Pilot%20(MPP).txt)

The team met and aligned on a realistic goal: maximizing automated compliance since even follow-on manual remediation isn't feasible at this scale.

* Automated Title tagging (via metadata). Successfully integrated PDFix CLI for font embedding, bookmarking, web links, and more.
* Identifying how to pass credentials through CLI actions is not understood yet, and addressing OCR limitations (scanned PDFs currently fail) is mostly unexplored still.
* Automated validation success remains elusive. Considering mini-cheats (e.g., generic alt-text for minority of figures lacking captions).
* Plan to test AWS Textract and a wider variety of dissertations.
* Refined the PDF analyzer script to provide more meaningful compliance summary reports.