# Markdown Ruby → ODT / DOCX Converter

Convert Markdown files containing `<ruby>` tags to standard office documents (ODT for LibreOffice, DOCX for Microsoft Word) with native ruby annotations.

## Features

- Converts `<ruby>base<rt>annotation</rt></ruby>` to native ruby in ODF (ODT) and OOXML (DOCX)
- Per-character ruby: spaces (half-width or full-width `　`) in `<rt>` split annotations across base characters
- Word-level fallback: ruby text without spaces is applied to the entire base word
- Centered ruby alignment above base text
- Interactive

## Requirements

- [pandoc](https://pandoc.org/) ≥ 3.0
- Python 3

## Quick Start

```bash
./converter.sh
```

## Markdown Syntax

```markdown
Word-level ruby:
<ruby>明日<rt>あした</rt></ruby>

Per-character ruby (space-separated):
<ruby>今日<rt>こん にち</rt></ruby>
<ruby>再见<rt>zai jian</rt></ruby>

Full-width spaces also work:
<ruby>今日<rt>こん　にち</rt></ruby>
```

## Project Files

| File | Purpose |
|------|---------|
| `converter.sh` | Interactive wrapper |
| `ruby-filter-docx.lua` | Pandoc Lua filter (DOCX output) |
| `ruby-filter-odt.lua` | Pandoc Lua filter (ODT output) |
| `post-process-odt.py` | Injects Ru1 ruby style into ODT |

## License

MIT

---

# Markdown Ruby → ODT / DOCX 转换器

将包含 `<ruby>` 标签的 Markdown 文件转换为带有原生注音标注的标准办公文档（ODT 用于 LibreOffice，DOCX 用于 Microsoft Word）。

## 功能

- 将 `<ruby>基准<rt>注音</rt></ruby>` 转换为 ODF (ODT) 和 OOXML (DOCX) 的原生注音
- 逐字注音：`<rt>` 中的空格（半角或全角 `　`）将注音按字拆分
- 词级回退：无空格的注音文字将标注在整个基准词上方
- 注音在基准文字上方居中显示
- 交互模式

## 环境要求

- [pandoc](https://pandoc.org/) ≥ 3.0
- Python 3

## 快速开始

```bash
./converter.sh
```

## Markdown 语法

```markdown
词级注音：
<ruby>明日<rt>あした</rt></ruby>

逐字注音（空格分隔）：
<ruby>今日<rt>こん にち</rt></ruby>
<ruby>再见<rt>zai jian</rt></ruby>

全角空格同样支持：
<ruby>今日<rt>こん　にち</rt></ruby>
```

## 项目文件

| 文件 | 用途 |
|------|------|
| `converter.sh` | 交互式包装脚本 |
| `ruby-filter-docx.lua` | Pandoc Lua 过滤器（DOCX 输出）|
| `ruby-filter-odt.lua` | Pandoc Lua 过滤器（ODT 输出）|
| `post-process-odt.py` | 向 ODT 注入 Ru1 注音样式 |

## 开源协议

MIT
