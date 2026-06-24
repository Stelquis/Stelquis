% ===================================================================
% 类名: resume
% ===================================================================
% 功能: 简历文档类，定义简历的页面布局、字体、标题格式和自定义命令
% 说明: 基于article类，专用于制作中文/英文简历，支持图标和进度条
% ===================================================================

% -----------------------------------------------------------------------------
% 第一部分: 基础设置
% -----------------------------------------------------------------------------

% 声明LaTeX版本和类信息
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}

% 加载基础article类，11pt字号
\LoadClass[11pt]{article}

% 取消段落缩进（简历通常不需要首行缩进）
\setlength{\parindent}{0pt}

% -----------------------------------------------------------------------------
% 第二部分: 依赖包加载
% -----------------------------------------------------------------------------

% LaTeX扩展和工具包
%   xltxtra:        XeLaTeX额外功能
%   xifthen:        条件判断支持
%   progressbar:    进度条支持
%   fix_linespacing:行距修复
\RequirePackage{xltxtra}
\RequirePackage{xifthen}
\RequirePackage{progressbar}
\RequirePackage{fix_linespacing}

% URL链接设置
%   \urlstyle{tt}:  URL使用等宽字体
%   hyperref:       超链接支持（可点击的链接）
\RequirePackage{url}
\urlstyle{tt}
\RequirePackage[colorlinks=true,linkcolor=black,urlcolor=black]{hyperref}

% 图标和字体支持
%   fontawesome:    Font Awesome图标
%   fontspec:       字体选择系统
\RequirePackage{fontawesome}
\RequirePackage{fontspec}

% -----------------------------------------------------------------------------
% 第三部分: 字体配置
% -----------------------------------------------------------------------------

% 英文字体: TeX Gyre Termes（Times New Roman风格）
% 配置说明:
%   Path:           字体文件路径
%   Extension:      文件扩展名
%   UprightFont:    正文字体
%   BoldFont:       粗体
%   ItalicFont:     斜体
%   BoldItalicFont: 粗斜体
%   SmallCapsFont:  小型大写字体
\setmainfont[
Path = ../assets/en-fonts/ ,
Extension = .otf ,
UprightFont = *-regular ,
BoldFont = *-bold ,
ItalicFont = *-italic ,
BoldItalicFont = *-bold-italic ,
SmallCapsFont = fontin-small-caps
]{tex-gyre-termes}

% -----------------------------------------------------------------------------
% 第四部分: 页面布局
% -----------------------------------------------------------------------------

% 页面设置: A4纸，窄边距
%   left/right:     左右边距15mm
%   top/bottom:     上下边距5mm
%   nohead:         无页眉
\RequirePackage[a4paper, left=15mm, right=15mm, top=5mm, bottom=5mm, nohead]{geometry}

% -----------------------------------------------------------------------------
% 第五部分: 标题和列表格式
% -----------------------------------------------------------------------------

% 标题格式包
\RequirePackage{titlesec}

% 列表格式包
%   noitemsep:      取消列表项间距
%   topsep:         列表顶部间距
%   leftmargin:     列表左边距
\RequirePackage{enumitem}
\setlist{noitemsep}
\setlist[itemize]{topsep=0.1em, leftmargin=1.5pc}
\setlist[enumerate]{topsep=0.1em, leftmargin=1.5pc}

% 序数词支持（1st, 2nd, 3rd等）- 暂未使用，如需启用请安装 texlive-latex-extra
% \RequirePackage[super]{nth}

% Section标题格式
%   字体:   大号小型大写
%   对齐:   左对齐
%   后缀:   下划线分隔线
\titleformat{\section}
{\large\scshape\raggedright}
{}{0em}
{}
[\vspace{-0.666em}\rule{18cm}{1.5pt}\vspace{-0.666em}]
\titlespacing*{\section}{0cm}{*0.333}{*1}

% Subsection标题格式
%   字体:   楷书大号
%   对齐:   左对齐
\titleformat{\subsection}
{\kaishu\large\raggedright}
{}{0em}
{}
\titlespacing*{\subsection}{0cm}{*0.5}{*0.5}

% -----------------------------------------------------------------------------
% 第六部分: 自定义命令 - 章节和日期
% -----------------------------------------------------------------------------

% 带日期的章节命令
% 用法: \datedsection{标题}{日期}
% 示例: \datedsection{教育背景}{2020-2024}
\newcommand{\datedsection}[2]{\section[#1]{#1 \hfill #2}}

% 带日期的子章节命令
% 用法: \datedsubsection{标题}{日期}
\newcommand{\datedsubsection}[2]{\subsection[#1]{#1 \hfill #2}}

% 带日期的行
% 用法: \datedline{内容}{日期}
\newcommand{\datedline}[2]{{\par #1 \hfill #2 \par}}

% -----------------------------------------------------------------------------
% 第七部分: 自定义命令 - 个人信息
% -----------------------------------------------------------------------------

% 姓名命令
% 功能: 居中显示大号姓名
% 用法: \name{张三}
\newcommand{\name}[1]{\centerline{\Huge\scshape{#1}}\vspace{1em}}

% 姓名测试命令（小号，用于调试）
\newcommand{\nameTest}[1]{{\large\scshape{#1}}}

% 邮箱命令（带信封图标）
% 用法: \email{zhangsan@email.com}
\newcommand{\email}[1]{\faEnvelope\ {\textbf{#1}}}

% 电话命令（带电话图标）
% 用法: \phone{138-0000-0000}
\newcommand{\phone}[1]{\faPhone\ {\textbf{#1}}}

% 微信命令（带微信图标）
% 用法: \Wechat{微信号}
\newcommand{\Wechat}[1]{\faWechat\ {\textbf{#1}}}

% LinkedIn命令（带LinkedIn图标和链接）
% 用法: \linkedin[显示名]{链接}
% 示例: \linkedin[我的LinkedIn]{https://linkedin.com/in/xxx}
\newcommand{\linkedin}[2][]{\faLinkedin\
\ifthenelse{\isempty{#1}}
{\href{#2}{#2}}
{\href{#2}{#1}}
}

% GitHub命令（带GitHub图标和链接）
% 用法: \github[显示名]{链接}
\newcommand{\github}[2][]{\faGithub\
\ifthenelse{\isempty{#1}}
{\href{#2}{#2}}
{\href{#2}{#1}}
}

% 主页命令（带链接图标）
% 用法: \homepage[显示名]{链接}
\newcommand{\homepage}[2][]{\faLink\
\ifthenelse{\isempty{#1}}
{\href{#2}{#2}}{\href{#2}{#1}}
}

% -----------------------------------------------------------------------------
% 第八部分: 自定义命令 - 技能和角色
% -----------------------------------------------------------------------------

% 进度条命令（用于技能水平展示）
% 用法: \pbar[宽度]{标签}{进度}
% 示例: \pbar[8em]{Python}{0.8}
% 参数:
%   #1: 进度条宽度（可选，默认10em）
%   #2: 技能名称
%   #3: 进度值（0-1之间）
\newcommand{\pbar}[3][10em]{{#2}\
\progressbar[heightr=1, width=#1, borderwidth=0pt, roundnessr=0.45, filledcolor=green!40, subdivisions=1]{#3}
}

% 基本信息命令
% 功能: 居中显示大号等宽字体信息
% 用法: \basicInfo{信息内容}
\newcommand{\basicInfo}[1]{\centerline{\ttfamily\large{#1}}\vspace{1.25ex}}

% 角色/职位命令
% 功能: 显示职位和时间/地点信息
% 用法: \role{职位}{时间/地点}
% 示例: \role{软件工程师}{2020.06-至今}
\newcommand{\role}[2]{
\vspace{-0.2em}
{
\par
\kaishu\textbf{#1} ~ \textit{#2}}
\vspace{-0.2em
}
}

\endinput
