#!/usr/bin/env python3
"""YAML / JSON 语法校验。

用法：
    python3 scripts/check-syntax.py

- 从仓库根目录开始扫描，无需在特定目录执行
- YAML 走 yaml.safe_load；JSON 先严格解析，失败再按 JSONC 重试
  （VS Code 的 .vscode/*.json 允许 // 注释与尾逗号）
- 语法错误时以非零状态码退出，供 CI 判定失败
"""

from __future__ import annotations

import glob
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKIP_PREFIX = ('repos/', '.git/', 'node_modules/')

YAML_PATTERNS = (
    '.github/**/*.yml',
    '.github/**/*.yaml',
    'course/**/*.yml',
    'course/**/*.yaml',
    '*.yml',
    '*.yaml',
    '.cnb.yml',
    '.cnb.yaml',
)

JSON_PATTERNS = (
    '**/*.json',
    '.vscode/*.json',
    '.devcontainer/*.json',
)

TRAILING_COMMA = re.compile(r',(\s*[}\]])')


def strip_jsonc(text: str) -> str:
    """去掉 // 与 /* */ 注释（跳过字符串内部）及尾逗号。"""
    out: list[str] = []
    i, size = 0, len(text)
    in_string = False
    escaped = False

    while i < size:
        char = text[i]
        if in_string:
            out.append(char)
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == '"':
                in_string = False
        elif char == '"':
            in_string = True
            out.append(char)
        elif char == '/' and i + 1 < size:
            if text[i + 1] == '/':
                while i < size and text[i] != '\n':
                    i += 1
                continue
            if text[i + 1] == '*':
                i += 2
                while i + 1 < size and not (text[i] == '*' and text[i + 1] == '/'):
                    i += 1
                i += 2
                continue
        else:
            out.append(char)
        i += 1

    return TRAILING_COMMA.sub(r'\1', ''.join(out))


def collect(patterns: tuple[str, ...]) -> list[Path]:
    """按 glob 收集文件，去重、排序并跳过无关目录。"""
    found = {
        path
        for pattern in patterns
        for path in glob.glob(pattern, root_dir=ROOT, recursive=True)
        if not path.startswith(SKIP_PREFIX)
    }
    return sorted(ROOT / name for name in found)


def check_yaml() -> list[str]:
    import yaml

    files = collect(YAML_PATTERNS)
    errors = []
    for path in files:
        try:
            yaml.safe_load(path.read_text(encoding='utf-8'))
        except Exception as exc:  # noqa: BLE001
            errors.append(f'{path.relative_to(ROOT)}: {exc}')
    report('YAML', files, errors)
    return errors


def check_json() -> list[str]:
    files = collect(JSON_PATTERNS)
    errors = []
    for path in files:
        raw = path.read_text(encoding='utf-8')
        try:
            json.loads(raw)
        except json.JSONDecodeError:
            try:
                json.loads(strip_jsonc(raw))
            except json.JSONDecodeError as exc:
                errors.append(f'{path.relative_to(ROOT)}: {exc}')
    report('JSON', files, errors)
    return errors


def report(kind: str, files: list[Path], errors: list[str]) -> None:
    print(f'{kind}: 已校验 {len(files)} 个文件')
    for path in files:
        print(f'  - {path.relative_to(ROOT)}')
    for line in errors:
        print(f'  ✗ {line}')


def main() -> int:
    errors = check_yaml() + check_json()
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
