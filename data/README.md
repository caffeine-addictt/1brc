---
license: apache-2.0
language:
- en
pretty_name: 1️⃣🐝🏎️ The One Billion Row Challenge - Data
size_categories:
- 1B<n<10B
viewer: false
---
# 1brc.data
1️⃣🐝🏎️ The One Billion Row Challenge - Data files only if you can't be bothered with Java 
or write a generator but would rather download +3GB 😁

See https://github.com/gunnarmorling/1brc for original Java challenge.

Large data files have been generated on my machine and given official Java generator is random
(not seeded and hence not deterministic) will be different than official files.

+10 million row files have been compressed with [7-zip](https://www.7-zip.org/) and split in 1GB volumes if needed.
Those files have been uploaded using git lfs. 

Expected output (`.out`) have been generated using Java implementations. Nothing has been done to verify results are correct.

Other files are from https://github.com/gunnarmorling/1brc/tree/main/src/test/resources/samples with expected outputs.

Download or clone with:
```
git clone https://huggingface.co/datasets/nietras/1brc.data
```