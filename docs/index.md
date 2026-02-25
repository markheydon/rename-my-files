---
title: Rename My Files
layout: home
---

# Rename My Files

**Rename My Files** is a free, open-source tool that automatically renames your files with clear, descriptive names — using AI to read the content and figure out what the file is actually about.

No more `scan0042.pdf` or `Document (3).docx`. Instead, you get:

- `Acme Ltd Invoice - February 2025.pdf`
- `HMRC Self Assessment Tax Return 2024-25.pdf`
- `Dr Smith Referral Letter - John Doe.docx`

---

## How It Works

1. You point the tool at a folder of files.
2. The tool reads each file's content.
3. It sends that content to Azure AI (privately, via your own Azure account).
4. Azure AI suggests a descriptive, human-readable name.
5. The tool renames the file, keeping the same extension.

Your files stay in the same folder — only their names change.

---

## Getting Started

👉 **New here? Start with the [User Guide](user-guide.md)** — it walks you through everything step by step, including how to set up Azure and run the tool.

---

## Limitations

- Only plain text files (`.txt`, `.md`, `.csv`, etc.) are fully supported out of the box.
- PDF and Office documents have limited support in the current version.
- Encrypted or corrupted files are skipped automatically.
- AI-generated names are suggestions — they may not always be perfect.

---

## Cost

Using this tool requires an Azure account. Costs are **very low** for typical use:

- Less than **$0.01 per document** in most cases.
- **No ongoing idle cost** — you only pay when the tool processes a file.

See the [User Guide](user-guide.md#cost) for more detail.

---

## Source & Contributions

- [View on GitHub](https://github.com/markheydon/rename-my-files)
- Licensed under the [MIT License](https://github.com/markheydon/rename-my-files/blob/main/LICENSE)
