from pathlib import Path

path = Path("build/web/index.html")
html = path.read_text(encoding="utf-8")

marker = "<!-- blackroot-mobile-landscape -->"
if marker not in html:
    injection = r"""
<!-- blackroot-mobile-landscape -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover, user-scalable=no">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<style>
html, body {
    margin: 0 !important;
    padding: 0 !important;
    width: 100% !important;
    height: 100% !important;
    min-height: 100dvh !important;
    overflow: hidden !important;
    overscroll-behavior: none !important;
    touch-action: none !important;
    background: #050805 !important;
}
#canvas {
    position: fixed !important;
    left: env(safe-area-inset-left, 0px) !important;
    top: env(safe-area-inset-top, 0px) !important;
    display: block !important;
    width: calc(100vw - env(safe-area-inset-left, 0px) - env(safe-area-inset-right, 0px)) !important;
    height: calc(100dvh - env(safe-area-inset-top, 0px) - env(safe-area-inset-bottom, 0px)) !important;
    max-width: none !important;
    max-height: none !important;
    touch-action: none !important;
    -webkit-user-select: none !important;
    user-select: none !important;
    -webkit-tap-highlight-color: transparent !important;
}
@media (orientation: portrait) and (pointer: coarse) {
    body::after {
        content: "BLACKROOT HOLLOW\A\A Rotate your phone to landscape";
        white-space: pre;
        position: fixed;
        inset: 0;
        z-index: 2147483647;
        display: grid;
        place-items: center;
        box-sizing: border-box;
        padding:
            calc(24px + env(safe-area-inset-top, 0px))
            calc(24px + env(safe-area-inset-right, 0px))
            calc(24px + env(safe-area-inset-bottom, 0px))
            calc(24px + env(safe-area-inset-left, 0px));
        text-align: center;
        font: 700 18px/1.45 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        letter-spacing: .08em;
        color: #f3ead8;
        background:
            radial-gradient(circle at center, rgba(69, 91, 49, .22), transparent 48%),
            #050805;
    }
    #canvas {
        visibility: hidden !important;
    }
}
</style>
"""
    if "</head>" not in html:
        raise SystemExit("Could not find </head> in exported Godot HTML")
    html = html.replace("</head>", injection + "\n</head>", 1)
    path.write_text(html, encoding="utf-8")

print("Applied Blackroot mobile landscape shell patch.")
