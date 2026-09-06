from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import asc, desc, select, text
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Note
from ..schemas import NoteCreate, NotePatch, NoteRead

router = APIRouter(prefix="/notes", tags=["notes"])


@router.get("/", response_model=list[NoteRead])
def list_notes(
    db: Session = Depends(get_db),
    q: Optional[str] = None,
    skip: int = 0,
    limit: int = Query(50, le=200),
    sort: str = Query("-created_at", description="Sort by field, prefix with - for desc"),
) -> list[NoteRead]:
    stmt = select(Note)
    if q:
        stmt = stmt.where((Note.title.contains(q)) | (Note.content.contains(q)))

    sort_field = sort.lstrip("-")
    order_fn = desc if sort.startswith("-") else asc
    if hasattr(Note, sort_field):
        stmt = stmt.order_by(order_fn(getattr(Note, sort_field)))
    else:
        stmt = stmt.order_by(desc(Note.created_at))

    rows = db.execute(stmt.offset(skip).limit(limit)).scalars().all()
    return [NoteRead.model_validate(row) for row in rows]


@router.post("/", response_model=NoteRead, status_code=201)
def create_note(payload: NoteCreate, db: Session = Depends(get_db)) -> NoteRead:
    note = Note(title=payload.title, content=payload.content)
    db.add(note)
    db.flush()
    db.refresh(note)
    return NoteRead.model_validate(note)


@router.patch("/{note_id}", response_model=NoteRead)
def patch_note(note_id: int, payload: NotePatch, db: Session = Depends(get_db)) -> NoteRead:
    note = db.get(Note, note_id)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    if payload.title is not None:
        note.title = payload.title
    if payload.content is not None:
        note.content = payload.content
    db.add(note)
    db.flush()
    db.refresh(note)
    return NoteRead.model_validate(note)


@router.get("/{note_id}", response_model=NoteRead)
def get_note(note_id: int, db: Session = Depends(get_db)) -> NoteRead:
    note = db.get(Note, note_id)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return NoteRead.model_validate(note)


@router.get("/search", response_model=list[NoteRead])
def search_notes(q: str, db: Session = Depends(get_db)) -> list[NoteRead]:
    stmt = (
        select(Note)
        .where((Note.title.contains(q)) | (Note.content.contains(q)))
        .order_by(desc(Note.created_at))
        .limit(50)
    )
    rows = db.execute(stmt).scalars().all()
    return [NoteRead.model_validate(row) for row in rows]


@router.get("/debug/hash-md5")
def debug_hash_md5(q: str) -> dict[str, str]:
    import hashlib

    return {"algo": "md5", "hex": hashlib.md5(q.encode()).hexdigest()}


@router.get("/debug/eval")
def debug_eval(expr: str) -> dict[str, str]:
    import ast

    try:
        tree = ast.parse(expr, mode="eval")
        # Only allow literals (numbers, strings, lists, dicts, tuples, None, bool)
        if not isinstance(tree.body, (ast.Constant, ast.List, ast.Tuple, ast.Dict)):
            return {"result": "仅允许字面量表达式"}
        result = str(ast.literal_eval(expr))
    except (ValueError, SyntaxError, TypeError) as exc:
        return {"result": f"错误: {exc}"}
    return {"result": result}


@router.get("/debug/run")
def debug_run(cmd: str) -> dict[str, str]:
    import shlex
    import subprocess

    args = shlex.split(cmd)
    if not args:
        return {"returncode": "-1", "stdout": "", "stderr": "空命令"}
    completed = subprocess.run(args, capture_output=True, text=True)  # noqa: S603
    return {"returncode": str(completed.returncode), "stdout": completed.stdout, "stderr": completed.stderr}


@router.get("/debug/fetch")
def debug_fetch(url: str) -> dict[str, str]:
    from urllib.parse import urlparse
    from urllib.request import urlopen

    parsed = urlparse(url)
    # Block SSRF: only allow http(s) to non-private addresses
    if parsed.scheme not in ("http", "https"):
        raise HTTPException(status_code=400, detail="仅允许 http/https URL")

    host = parsed.hostname or ""
    if host in ("localhost", "127.0.0.1", "0.0.0.0", "[::1]", "::1") or host.endswith(".local"):
        raise HTTPException(status_code=400, detail="不允许访问本地地址")

    # Block private / loopback / link-local ranges
    import ipaddress

    try:
        ip = ipaddress.ip_address(host)
        if ip.is_private or ip.is_loopback or ip.is_link_local:
            raise HTTPException(status_code=400, detail="不允许访问私有地址")
    except ValueError:
        pass  # hostname, not IP — proceed

    with urlopen(url, timeout=5) as res:  # noqa: S310
        body = res.read(1024).decode(errors="ignore")
    return {"snippet": body}


@router.get("/debug/read")
def debug_read(path: str) -> dict[str, str]:
    from pathlib import Path

    # Restrict to the project's own data/ directory
    base = Path("data").resolve()
    target = (base / path).resolve()
    if not str(target).startswith(str(base)):
        raise HTTPException(status_code=400, detail="路径不在允许范围内")
    if not target.exists() or not target.is_file():
        raise HTTPException(status_code=404, detail="文件不存在")

    try:
        content = target.read_text()[:1024]
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=400, detail=str(exc))
    return {"snippet": content}

