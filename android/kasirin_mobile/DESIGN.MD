<!-- Cashier POS - Dashboard & Laporan -->
<!DOCTYPE html>

<html class="dark" lang="en"><head><meta charset="utf-8"/><meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" name="viewport"/><meta content="mobile_tab" name="shell-type"/><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Plus+Jakarta+Sans:wght@600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/><style>@layer base{html,body{width:100vw;margin:0;padding:0;}body{overscroll-behavior:none;}.pb-safe{padding-bottom:env(safe-area-inset-bottom,0px);}.pt-safe{padding-top:env(safe-area-inset-top,0px);}main>:first-child{margin-top:0!important;}main>:last-child{margin-bottom:0!important;}}::-webkit-scrollbar{display:none;}</style><script src="https://cdn.tailwindcss.com"></script><script id="tailwind-config">tailwind.config = { darkMode: "class", theme: { extend: { colors: { "surface-container": "#171f33", "surface-variant": "#2d3449", "surface-tint": "#00e297", "error-container": "#93000a", "on-tertiary-container": "#774a00", "on-primary": "#003822", "surface": "#0b1326", "on-secondary-fixed-variant": "#2f2ebe", "tertiary-fixed-dim": "#ffb95f", "surface-container-high": "#222a3d", "inverse-on-surface": "#283044", "surface-bright": "#31394d", "outline": "#849589", "background": "#0b1326", "tertiary-fixed": "#ffddb8", "on-primary-fixed": "#002112", "primary-fixed-dim": "#00e297", "on-background": "#dae2fd", "on-secondary-container": "#b0b2ff", "surface-container-low": "#131b2e", "tertiary-container": "#ffbc68", "on-error": "#690005", "inverse-surface": "dae2fd", "on-tertiary": "#472a00", "secondary-container": "#3131c0", "outline-variant": "#3b4a41", "inverse-primary": "#006c46", "primary": "#6dffba", "on-surface": "#dae2fd", "surface-dim": "#0b1326", "on-surface-variant": "#bacbbe", "surface-container-lowest": "#060e20", "primary-fixed": "#4dffb2", "on-secondary-fixed": "#07006c", "on-primary-container": "#00613e", "primary-container": "#00e599", "secondary-fixed": "#e1e0ff", "secondary-fixed-dim": "#c0c1ff", "surface-container-highest": "#2d3449", "on-primary-fixed-variant": "#005234", "secondary": "#c0c1ff", "error": "#ffb4ab", "on-secondary": "#1000a9", "on-error-container": "#ffdad6", "on-tertiary-fixed-variant": "#653e00", "on-tertiary-fixed": "#2a1700", "tertiary": "#ffe0be" }, borderRadius: { "DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px" }, spacing: { "margin": "1rem", "space-lg": "1.25rem", "space-sm": "0.5rem", "space-xs": "0.25rem", "space-md": "0.75rem", "space-xl": "2rem", "gutter-tablet": "1rem", "margin-tablet": "1.5rem", "gutter": "0.75rem" }, fontFamily: { "label-md": ["Inter"], "body-lg": ["Inter"], "body-md": ["Inter"], "headline-md": ["Plus Jakarta Sans"], "label-sm": ["Inter"], "numeric-keypad": ["Plus Jakarta Sans"], "numeric-display": ["Plus Jakarta Sans"], "label-lg": ["Inter"], "headline-xl": ["Plus Jakarta Sans"], "headline-lg": ["Plus Jakarta Sans"], "headline-xl-mobile": ["Plus Jakarta Sans"], "body-sm": ["Inter"] }, fontSize: { "label-md": ["13px", { "lineHeight": "16px", "letterSpacing": "0.02em", "fontWeight": "600" }], "body-lg": ["17px", { "lineHeight": "24px", "fontWeight": "500" }], "body-md": ["15px", { "lineHeight": "22px", "fontWeight": "400" }], "headline-md": ["22px", { "lineHeight": "28px", "fontWeight": "600" }], "label-sm": ["11px", { "lineHeight": "14px", "letterSpacing": "0.04em", "fontWeight": "700" }], "numeric-keypad": ["24px", { "lineHeight": "28px", "fontWeight": "600" }], "numeric-display": ["32px", { "lineHeight": "38px", "letterSpacing": "-0.02em", "fontWeight": "800" }], "label-lg": ["15px", { "lineHeight": "20px", "letterSpacing": "0.01em", "fontWeight": "600" }], "headline-xl": ["40px", { "lineHeight": "48px", "letterSpacing": "-0.02em", "fontWeight": "700" }], "headline-lg": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.01em", "fontWeight": "700" }], "headline-xl-mobile": ["30px", { "lineHeight": "36px", "letterSpacing": "-0.02em", "fontWeight": "700" }], "body-sm": ["13px", { "lineHeight": "18px", "fontWeight": "400" }] } } } };</script><style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head><body class="bg-surface font-body-md text-on-surface min-h-screen flex flex-col selection:bg-primary selection:text-on-primary"><header class="fixed top-0 w-full z-50 pt-safe bg-surface-container-lowest/90 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]"><div class="h-16 px-margin flex items-center justify-between gap-space-sm"><div class="flex items-center gap-space-sm min-w-0"><div class="flex items-center gap-space-xs bg-surface-container-high px-space-sm py-space-xs rounded-lg"><span class="w-2 h-2 rounded-full bg-primary-container animate-pulse"></span><span class="font-label-sm text-label-sm text-primary uppercase">Term 04</span></div><div class="flex flex-col min-w-0"><span class="font-headline-md text-body-md font-bold text-on-surface truncate">Cashier Register</span><span class="font-label-sm text-label-sm text-on-surface-variant flex items-center gap-1"><span class="material-symbols-outlined text-[12px] text-primary">schedule</span> 04:18:22</span></div></div><div class="flex items-center gap-space-sm"><button aria-label="Search Catalog or Scan Barcode" class="w-11 h-11 rounded-xl bg-surface-container-high hover:bg-surface-variant flex items-center justify-center text-on-surface-variant hover:text-on-surface transition-colors"><span class="material-symbols-outlined text-[20px]">barcode_scanner</span></button><button aria-label="Cashier Profile" class="flex items-center gap-space-xs pl-space-xs rounded-full hover:bg-surface-container-high transition-colors"><img alt="Profile" class="w-8 h-8 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida/AEtjO1X3q5n5Qeu54RKL6HFUarPePU4H-knzl_0DUp00Acwg2lCP89sAGszi0XxE6gh7gBfEKHYQ-uRboJ0WYSZ9U66mHr6sm0r2blBLnGYC19yRTyzfPG9suQXNwVGy2a5baLj-nXWqq1Kh6XUxgax5pno4rwIrCenUEekhaM7oKEUneV11coG4QLFhuG4QYMp8Akjzq6s7YLS3g6I_UW0LRn2JrRzlnxhpJLaF_QIb9xhHcA"/></button></div></div></header><main class="flex-1 w-full bg-surface pt-16 pb-28 min-h-screen"><div class="flex flex-col w-full px-margin pb-space-lg">
<div class="relative w-full rounded-2xl overflow-hidden bg-surface-container-high shadow-lg mt-space-sm">
<div class="absolute inset-0 bg-cover bg-center opacity-30" data-alt="Dark atmospheric specialty coffee roastery interior with sleek matte black espresso machines, neon mint rim highlights, polished concrete counters, warm amber ambient lamps, and artisan coffee bags lined neatly under low key cinema lighting" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCAeyIj00hbWOGqJKhfPWYTn7H4UKiNrAdjprP91uiyoegQ7BIjgIeWTsEprcUjYoYpIl5QlT444kiXrXUudvctSixdvB7aNLwyqs7n9EKDQergHMiw4wcWHJC9yh_opPJDMRkHM5Ho-gcNDBlp8XRYGbYknXX8JeIOYiYvTV_hRV3qhhquHfvzNJZAncXw9Q3FReGMFzydV9ilmkCqIEH1sXSaNzIQ03ZwbV5Er8Da')"></div>
<div class="absolute inset-0 bg-gradient-to-r from-surface-container-lowest/95 via-surface-container/85 to-surface-container-high/70 backdrop-blur-sm"></div>
<div class="relative p-space-md flex flex-col gap-space-md">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-sm">
<div class="relative w-12 h-12 rounded-xl bg-surface-container-highest flex items-center justify-center shadow-md">
<span class="material-symbols-outlined text-primary text-[26px]" style="font-variation-settings: 'FILL' 1;">local_cafe</span>
<span class="absolute -bottom-1 -right-1 w-3.5 h-3.5 rounded-full bg-primary-container ring-2 ring-surface-container-lowest"></span>
</div>
<div class="flex flex-col min-w-0">
<div class="flex items-center gap-space-xs">
<span class="font-headline-md text-headline-md text-on-surface tracking-tight truncate">Kopi Kinetic</span>
<span class="px-space-xs py-0.5 rounded bg-surface-variant text-on-surface-variant font-label-sm text-label-sm">#01</span>
</div>
<span class="font-body-sm text-body-sm text-on-surface-variant flex items-center gap-1">
<span class="material-symbols-outlined text-[13px] text-tertiary-container">wb_sunny</span>
              Shift Pagi • Budi Santoso
            </span>
</div>
</div>
<div class="flex items-center gap-space-xs">
<button aria-label="Notifikasi" class="relative w-10 h-10 rounded-xl bg-surface-container-low hover:bg-surface-variant text-on-surface-variant hover:text-on-surface flex items-center justify-center transition-all active:scale-95">
<span class="material-symbols-outlined text-[20px]">notifications</span>
<span class="absolute top-2 right-2 w-2 h-2 rounded-full bg-tertiary-container"></span>
</button>
<button aria-label="Kunci Register" class="w-10 h-10 rounded-xl bg-surface-container-low hover:bg-surface-variant text-on-surface-variant hover:text-on-surface flex items-center justify-center transition-all active:scale-95">
<span class="material-symbols-outlined text-[20px]">lock_open</span>
</button>
</div>
</div>
<div class="flex items-center justify-between pt-space-xs bg-surface-container-lowest/60 rounded-xl p-space-sm">
<div class="flex items-center gap-space-xs text-on-surface-variant font-label-sm text-label-sm">
<span class="w-2 h-2 rounded-full bg-primary-container animate-ping"></span>
<span class="text-on-surface font-semibold">Kasir Aktif:</span>
<span>Reg-04 (LAN Online)</span>
</div>
<div class="flex items-center gap-space-xs bg-surface-container-high px-space-sm py-0.5 rounded-lg text-primary font-label-sm text-label-sm">
<span class="material-symbols-outlined text-[13px]">sync</span>
          Sync 1m lalu
        </div>
</div>
</div>
</div>
<div class="w-full mt-space-md">
<div class="flex items-center justify-between mb-space-xs">
<span class="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant">Aksi Cepat Kasir</span>
<span class="font-label-sm text-label-sm text-primary">6 Modul</span>
</div>
<div class="flex gap-space-sm overflow-x-auto pb-space-xs -mx-margin px-margin no-scrollbar">
<button class="flex items-center gap-space-xs px-space-md py-space-sm rounded-xl bg-primary-container text-on-primary font-label-md text-label-md shrink-0 shadow-md active:scale-95 transition-all">
<span class="material-symbols-outlined text-[18px]" style="font-variation-settings: 'FILL' 1;">point_of_sale</span>
<span>Buka Kasir</span>
</button>
<button class="flex items-center gap-space-xs px-space-md py-space-sm rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface font-label-md text-label-md shrink-0 active:scale-95 transition-all">
<span class="material-symbols-outlined text-[18px] text-primary">add_shopping_cart</span>
<span>Order Baru</span>
</button>
<button class="flex items-center gap-space-xs px-space-md py-space-sm rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface font-label-md text-label-md shrink-0 active:scale-95 transition-all">
<span class="material-symbols-outlined text-[18px] text-secondary">receipt_long</span>
<span>Riwayat Transaksi</span>
</button>
<button class="flex items-center gap-space-xs px-space-md py-space-sm rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface font-label-md text-label-md shrink-0 active:scale-95 transition-all">
<span class="material-symbols-outlined text-[18px] text-tertiary-fixed-dim">inventory_2</span>
<span>Manajemen Stok</span>
</button>
<button class="flex items-center gap-space-xs px-space-md py-space-sm rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface font-label-md text-label-md shrink-0 active:scale-95 transition-all">
<span class="material-symbols-outlined text-[18px] text-error">assignment_turned_in</span>
<span>Tutup Shift (Z)</span>
</button>
<button class="flex items-center gap-space-xs px-space-md py-space-sm rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface font-label-md text-label-md shrink-0 active:scale-95 transition-all">
<span class="material-symbols-outlined text-[18px] text-primary">loyalty</span>
<span>Diskon &amp; Promo</span>
</button>
</div>
</div>
<div class="w-full mt-space-md flex flex-col gap-space-md">
<div class="w-full rounded-2xl bg-surface-container p-space-md flex flex-col gap-space-md shadow-lg relative overflow-hidden">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<div class="w-8 h-8 rounded-lg bg-surface-container-high flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[18px]">query_stats</span>
</div>
<div>
<h2 class="font-headline-md text-body-lg text-on-surface font-bold">Penjualan Hari Ini</h2>
<span class="font-label-sm text-label-sm text-on-surface-variant">Update 14:32 WIB</span>
</div>
</div>
<div class="flex items-center gap-1 bg-surface-container-high px-space-sm py-1 rounded-full text-primary font-label-sm text-label-sm">
<span class="material-symbols-outlined text-[14px]">trending_up</span>
          +18.4%
        </div>
</div>
<div class="flex flex-col">
<div class="flex items-baseline gap-space-xs">
<span class="font-headline-xl-mobile text-headline-xl-mobile text-primary tracking-tight font-extrabold">Rp 4.850.000</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">Gross</span>
</div>
<span class="font-body-sm text-body-sm text-on-surface-variant">Target Harian: Rp 6.000.000 (80.8% tercapai)</span>
</div>
<div class="w-full bg-surface-container-lowest/80 p-space-sm rounded-xl flex flex-col gap-space-xs">
<div class="flex items-center justify-between text-on-surface-variant font-label-sm text-label-sm">
<span>Aktivitas Jam Sibuk (Rush Hour)</span>
<span class="text-primary font-semibold">Puncak: 12:00 - 14:00</span>
</div>
<div class="h-20 w-full flex items-end gap-1.5 pt-2">
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-surface-variant rounded-t-sm h-[25%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">08</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-surface-variant rounded-t-sm h-[40%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">09</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-surface-variant rounded-t-sm h-[55%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">10</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-surface-variant rounded-t-sm h-[50%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">11</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-primary-container rounded-t-sm h-[88%] shadow-[0_0_8px_rgba(0,229,153,0.35)]"></div>
<span class="font-label-sm text-[9px] text-primary font-bold">12</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-primary-container rounded-t-sm h-[100%] shadow-[0_0_8px_rgba(0,229,153,0.4)]"></div>
<span class="font-label-sm text-[9px] text-primary font-bold">13</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-primary rounded-t-sm h-[70%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">14</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-surface-variant rounded-t-sm h-[45%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">15</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-surface-variant rounded-t-sm h-[30%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">16</span>
</div>
<div class="flex-1 flex flex-col items-center gap-1 h-full justify-end">
<div class="w-full bg-surface-variant rounded-t-sm h-[20%]"></div>
<span class="font-label-sm text-[9px] text-on-surface-variant">17</span>
</div>
</div>
</div>
<div class="grid grid-cols-2 gap-space-sm pt-space-xs">
<div class="bg-surface-container-high p-space-sm rounded-xl flex flex-col">
<span class="font-label-sm text-label-sm text-on-surface-variant flex items-center gap-1">
<span class="material-symbols-outlined text-[14px] text-secondary">shopping_bag</span>
            Total Pesanan
          </span>
<span class="font-headline-md text-headline-md text-on-surface mt-1">142</span>
<span class="font-label-sm text-label-sm text-primary">+12 pesanan/jam</span>
</div>
<div class="bg-surface-container-high p-space-sm rounded-xl flex flex-col">
<span class="font-label-sm text-label-sm text-on-surface-variant flex items-center gap-1">
<span class="material-symbols-outlined text-[14px] text-tertiary-container">payments</span>
            Rata-rata Tiket (AOV)
          </span>
<span class="font-headline-md text-headline-md text-on-surface mt-1">Rp 34.150</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">~2.4 item/tiket</span>
</div>
</div>
</div>
<div class="w-full rounded-2xl bg-surface-container p-space-md flex flex-col gap-space-md shadow-lg">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<div class="w-8 h-8 rounded-lg bg-surface-container-high flex items-center justify-center text-tertiary-fixed-dim">
<span class="material-symbols-outlined text-[18px]">warning</span>
</div>
<div class="flex flex-col">
<h3 class="font-headline-md text-body-lg text-on-surface font-bold">Peringatan Stok Rendah</h3>
<span class="font-label-sm text-label-sm text-on-surface-variant">Bahan baku &amp; bakery kritis</span>
</div>
</div>
<span class="px-space-sm py-1 rounded-full bg-error-container text-on-error-container font-label-sm text-label-sm font-bold">
          3 Kritis
        </span>
</div>
<div class="flex flex-col gap-space-sm">
<div class="p-space-sm rounded-xl bg-surface-container-high flex flex-col gap-space-xs">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-tertiary-container text-[18px]">bakery_dining</span>
<span class="font-label-lg text-label-lg text-on-surface font-semibold">Almond Croissant</span>
</div>
<span class="font-label-sm text-label-sm text-error font-bold">Sisa 4 pcs</span>
</div>
<div class="w-full bg-surface-container-lowest h-2 rounded-full overflow-hidden">
<div class="bg-error h-full rounded-full w-[16%]"></div>
</div>
<div class="flex items-center justify-between text-on-surface-variant font-label-sm text-label-sm">
<span>Batas minimum: 25 pcs</span>
<span class="text-error">Kritis (16%)</span>
</div>
</div>
<div class="p-space-sm rounded-xl bg-surface-container-high flex flex-col gap-space-xs">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-secondary text-[18px]">nutrition</span>
<span class="font-label-lg text-label-lg text-on-surface font-semibold">Fresh Milk Diamond 1L</span>
</div>
<span class="font-label-sm text-label-sm text-tertiary-fixed-dim font-bold">Sisa 3 btl</span>
</div>
<div class="w-full bg-surface-container-lowest h-2 rounded-full overflow-hidden">
<div class="bg-tertiary-container h-full rounded-full w-[22%]"></div>
</div>
<div class="flex items-center justify-between text-on-surface-variant font-label-sm text-label-sm">
<span>Batas minimum: 15 btl</span>
<span class="text-tertiary-fixed-dim">Perlu restock (22%)</span>
</div>
</div>
<div class="p-space-sm rounded-xl bg-surface-container-high flex flex-col gap-space-xs">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-primary text-[18px]">coffee_maker</span>
<span class="font-label-lg text-label-lg text-on-surface font-semibold">Ethiopia Guji Beans</span>
</div>
<span class="font-label-sm text-label-sm text-tertiary-fixed-dim font-bold">Sisa 800g</span>
</div>
<div class="w-full bg-surface-container-lowest h-2 rounded-full overflow-hidden">
<div class="bg-tertiary-container h-full rounded-full w-[28%]"></div>
</div>
<div class="flex items-center justify-between text-on-surface-variant font-label-sm text-label-sm">
<span>Batas minimum: 3.000g</span>
<span class="text-tertiary-fixed-dim">Tersisa ~40 cup</span>
</div>
</div>
</div>
<button class="w-full py-space-sm rounded-xl bg-surface-container-highest hover:bg-surface-variant text-on-surface font-label-md text-label-md flex items-center justify-center gap-space-xs transition-colors active:scale-98">
<span class="material-symbols-outlined text-[18px] text-primary">add_business</span>
<span>Buat Order Pembelian / PO Vendor</span>
</button>
</div>
<div class="w-full rounded-2xl bg-surface-container p-space-md flex flex-col gap-space-md shadow-lg">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<div class="w-8 h-8 rounded-lg bg-surface-container-high flex items-center justify-center text-secondary">
<span class="material-symbols-outlined text-[18px]">account_balance_wallet</span>
</div>
<h3 class="font-headline-md text-body-lg text-on-surface font-bold">Metode Pembayaran</h3>
</div>
<span class="font-label-sm text-label-sm text-on-surface-variant">142 Transaksi</span>
</div>
<div class="flex flex-col gap-space-sm">
<div class="flex items-center justify-between p-space-sm bg-surface-container-high rounded-xl">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-9 h-9 rounded-lg bg-primary/20 flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[20px]">qr_code_scanner</span>
</div>
<div class="flex flex-col min-w-0">
<span class="font-label-lg text-label-lg text-on-surface font-semibold truncate">QRIS &amp; E-Wallet</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">91 transaksi (64%)</span>
</div>
</div>
<div class="flex flex-col items-end">
<span class="font-label-lg text-label-lg text-primary font-bold">Rp 3.104.000</span>
<span class="font-label-sm text-label-sm text-primary">Biaya MDR 0%</span>
</div>
</div>
<div class="flex items-center justify-between p-space-sm bg-surface-container-high rounded-xl">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-9 h-9 rounded-lg bg-tertiary-container/20 flex items-center justify-center text-tertiary-fixed-dim">
<span class="material-symbols-outlined text-[20px]">payments</span>
</div>
<div class="flex flex-col min-w-0">
<span class="font-label-lg text-label-lg text-on-surface font-semibold truncate">Tunai / Cash</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">31 transaksi (22%)</span>
</div>
</div>
<div class="flex flex-col items-end">
<span class="font-label-lg text-label-lg text-on-surface font-bold">Rp 1.067.000</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">Kas Masuk</span>
</div>
</div>
<div class="flex items-center justify-between p-space-sm bg-surface-container-high rounded-xl">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-9 h-9 rounded-lg bg-secondary/20 flex items-center justify-center text-secondary">
<span class="material-symbols-outlined text-[20px]">credit_card</span>
</div>
<div class="flex flex-col min-w-0">
<span class="font-label-lg text-label-lg text-on-surface font-semibold truncate">Kartu Debit &amp; EDC</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">20 transaksi (14%)</span>
</div>
</div>
<div class="flex flex-col items-end">
<span class="font-label-lg text-label-lg text-on-surface font-bold">Rp 679.000</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">BCA &amp; Mandiri</span>
</div>
</div>
</div>
</div>
<div class="w-full rounded-2xl bg-surface-container-low p-space-md flex flex-col gap-space-sm shadow-md">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-primary text-[20px]">point_of_sale</span>
<span class="font-label-lg text-label-lg text-on-surface font-bold">Kas di Laci (Drawer Total)</span>
</div>
<span class="font-label-sm text-label-sm text-primary">Modal Awal: Rp 200.000</span>
</div>
<div class="flex items-center justify-between bg-surface-container p-space-sm rounded-xl">
<div class="flex flex-col">
<span class="font-label-sm text-label-sm text-on-surface-variant">Total Fisik Estimasi</span>
<span class="font-headline-md text-headline-md text-primary font-bold">Rp 1.267.000</span>
</div>
<button class="px-space-md py-space-xs rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface font-label-md text-label-md flex items-center gap-1 active:scale-95 transition-all">
<span class="material-symbols-outlined text-[16px] text-tertiary-container">calculate</span>
<span>Hitung Fisik</span>
</button>
</div>
</div>
<div class="w-full rounded-2xl bg-surface-container p-space-md flex flex-col gap-space-sm shadow-md">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-primary text-[18px]">verified</span>
<h3 class="font-headline-md text-body-lg text-on-surface font-bold">Item Terlaris Hari Ini</h3>
</div>
<span class="font-label-sm text-label-sm text-primary">Top 3</span>
</div>
<div class="flex flex-col gap-space-xs">
<div class="flex items-center justify-between py-1.5">
<div class="flex items-center gap-space-sm">
<span class="w-5 font-headline-md text-body-md text-primary font-bold">1</span>
<div class="flex flex-col">
<span class="font-label-md text-label-md text-on-surface">Kinetic Iced Aren Latte</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">58 cup terjual</span>
</div>
</div>
<span class="font-label-md text-label-md text-on-surface font-semibold">Rp 1.624.000</span>
</div>
<div class="flex items-center justify-between py-1.5">
<div class="flex items-center gap-space-sm">
<span class="w-5 font-headline-md text-body-md text-secondary font-bold">2</span>
<div class="flex flex-col">
<span class="font-label-md text-label-md text-on-surface">Cold Brew Nitro Vanilla</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">34 cup terjual</span>
</div>
</div>
<span class="font-label-md text-label-md text-on-surface font-semibold">Rp 1.122.000</span>
</div>
<div class="flex items-center justify-between py-1.5">
<div class="flex items-center gap-space-sm">
<span class="w-5 font-headline-md text-body-md text-tertiary-fixed-dim font-bold">3</span>
<div class="flex flex-col">
<span class="font-label-md text-label-md text-on-surface">Almond Croissant Warm</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">21 pcs terjual</span>
</div>
</div>
<span class="font-label-md text-label-md text-on-surface font-semibold">Rp 693.000</span>
</div>
</div>
</div>
</div>
</div></main><nav class="fixed bottom-0 w-full z-50 pb-safe bg-surface-container-lowest/95 backdrop-blur-xl shadow-[0_-8px_24px_rgba(0,0,0,0.45)]" data-active-classes="bg-surface-container text-primary font-bold"><div class="px-margin pt-space-xs pb-space-sm flex items-center justify-between gap-space-sm"><button class="flex items-center gap-space-xs px-space-md py-space-sm h-14 rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface-variant hover:text-on-surface transition-all active:scale-95"><span class="material-symbols-outlined text-[20px]">pause_circle</span><span class="font-label-md text-label-md">Hold</span></button><div class="flex-1 flex items-center justify-between px-space-md h-14 rounded-xl bg-surface-container-low"><div class="flex flex-col"><span class="font-label-sm text-label-sm text-on-surface-variant">Active Ticket</span><span class="font-label-lg text-label-lg text-on-surface font-semibold">3 items</span></div><span class="font-headline-md text-headline-md text-primary font-bold">$24.50</span></div><button class="flex items-center justify-center gap-space-xs px-space-lg h-14 rounded-xl bg-primary-container hover:bg-primary text-on-primary font-bold active:scale-95 transition-all shadow-[0_0_16px_rgba(0,229,153,0.3)]"><span class="font-label-lg text-label-lg uppercase tracking-wider font-extrabold">Pay</span><span class="material-symbols-outlined text-[22px]">arrow_forward</span></button></div><div class="flex items-center justify-around h-14 px-margin bg-surface-container-lowest"><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="catalog" href="#"><span class="material-symbols-outlined text-[22px]">grid_view</span><span class="font-label-sm text-label-sm">Register</span></a><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="tickets" href="#"><span class="material-symbols-outlined text-[22px]">receipt_long</span><span class="font-label-sm text-label-sm">Tickets</span></a><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="activity" href="#"><span class="material-symbols-outlined text-[22px]">history</span><span class="font-label-sm text-label-sm">History</span></a><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="more-menu" href="#"><span class="material-symbols-outlined text-[22px]">menu</span><span class="font-label-sm text-label-sm">Menu</span></a></div></nav></body></html>

<!-- Cashier POS - Buka Kasir -->
<!DOCTYPE html>

<html class="dark" lang="en"><head><meta charset="utf-8"/><meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" name="viewport"/><meta content="mobile_tab" name="shell-type"/><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Plus+Jakarta+Sans:wght@600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/><style>@layer base{html,body{width:100vw;margin:0;padding:0;}body{overscroll-behavior:none;}.pb-safe{padding-bottom:env(safe-area-inset-bottom,0px);}.pt-safe{padding-top:env(safe-area-inset-top,0px);}main>:first-child{margin-top:0!important;}main>:last-child{margin-bottom:0!important;}}::-webkit-scrollbar{display:none;}</style><script src="https://cdn.tailwindcss.com"></script><script id="tailwind-config">tailwind.config = { darkMode: "class", theme: { extend: { colors: { "surface-container": "#171f33", "surface-variant": "#2d3449", "surface-tint": "#00e297", "error-container": "#93000a", "on-tertiary-container": "#774a00", "on-primary": "#003822", "surface": "#0b1326", "on-secondary-fixed-variant": "#2f2ebe", "tertiary-fixed-dim": "#ffb95f", "surface-container-high": "#222a3d", "inverse-on-surface": "#283044", "surface-bright": "#31394d", "outline": "#849589", "background": "#0b1326", "tertiary-fixed": "#ffddb8", "on-primary-fixed": "#002112", "primary-fixed-dim": "#00e297", "on-background": "#dae2fd", "on-secondary-container": "#b0b2ff", "surface-container-low": "#131b2e", "tertiary-container": "#ffbc68", "on-error": "#690005", "inverse-surface": "dae2fd", "on-tertiary": "#472a00", "secondary-container": "#3131c0", "outline-variant": "#3b4a41", "inverse-primary": "#006c46", "primary": "#6dffba", "on-surface": "#dae2fd", "surface-dim": "#0b1326", "on-surface-variant": "#bacbbe", "surface-container-lowest": "#060e20", "primary-fixed": "#4dffb2", "on-secondary-fixed": "#07006c", "on-primary-container": "#00613e", "primary-container": "#00e599", "secondary-fixed": "#e1e0ff", "secondary-fixed-dim": "#c0c1ff", "surface-container-highest": "#2d3449", "on-primary-fixed-variant": "#005234", "secondary": "#c0c1ff", "error": "#ffb4ab", "on-secondary": "#1000a9", "on-error-container": "#ffdad6", "on-tertiary-fixed-variant": "#653e00", "on-tertiary-fixed": "#2a1700", "tertiary": "#ffe0be" }, borderRadius: { "DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px" }, spacing: { "margin": "1rem", "space-lg": "1.25rem", "space-sm": "0.5rem", "space-xs": "0.25rem", "space-md": "0.75rem", "space-xl": "2rem", "gutter-tablet": "1rem", "margin-tablet": "1.5rem", "gutter": "0.75rem" }, fontFamily: { "label-md": ["Inter"], "body-lg": ["Inter"], "body-md": ["Inter"], "headline-md": ["Plus Jakarta Sans"], "label-sm": ["Inter"], "numeric-keypad": ["Plus Jakarta Sans"], "numeric-display": ["Plus Jakarta Sans"], "label-lg": ["Inter"], "headline-xl": ["Plus Jakarta Sans"], "headline-lg": ["Plus Jakarta Sans"], "headline-xl-mobile": ["Plus Jakarta Sans"], "body-sm": ["Inter"] }, fontSize: { "label-md": ["13px", { "lineHeight": "16px", "letterSpacing": "0.02em", "fontWeight": "600" }], "body-lg": ["17px", { "lineHeight": "24px", "fontWeight": "500" }], "body-md": ["15px", { "lineHeight": "22px", "fontWeight": "400" }], "headline-md": ["22px", { "lineHeight": "28px", "fontWeight": "600" }], "label-sm": ["11px", { "lineHeight": "14px", "letterSpacing": "0.04em", "fontWeight": "700" }], "numeric-keypad": ["24px", { "lineHeight": "28px", "fontWeight": "600" }], "numeric-display": ["32px", { "lineHeight": "38px", "letterSpacing": "-0.02em", "fontWeight": "800" }], "label-lg": ["15px", { "lineHeight": "20px", "letterSpacing": "0.01em", "fontWeight": "600" }], "headline-xl": ["40px", { "lineHeight": "48px", "letterSpacing": "-0.02em", "fontWeight": "700" }], "headline-lg": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.01em", "fontWeight": "700" }], "headline-xl-mobile": ["30px", { "lineHeight": "36px", "letterSpacing": "-0.02em", "fontWeight": "700" }], "body-sm": ["13px", { "lineHeight": "18px", "fontWeight": "400" }] } } } };</script><style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head><body class="bg-surface font-body-md text-on-surface min-h-screen flex flex-col selection:bg-primary selection:text-on-primary"><header class="fixed top-0 w-full z-50 pt-safe bg-surface-container-lowest/90 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]"><div class="h-16 px-margin flex items-center justify-between gap-space-sm"><div class="flex items-center gap-space-sm min-w-0"><div class="flex items-center gap-space-xs bg-surface-container-high px-space-sm py-space-xs rounded-lg"><span class="w-2 h-2 rounded-full bg-primary-container animate-pulse"></span><span class="font-label-sm text-label-sm text-primary uppercase">Term 04</span></div><div class="flex flex-col min-w-0"><span class="font-headline-md text-body-md font-bold text-on-surface truncate">Cashier Register</span><span class="font-label-sm text-label-sm text-on-surface-variant flex items-center gap-1"><span class="material-symbols-outlined text-[12px] text-primary">schedule</span> 04:18:22</span></div></div><div class="flex items-center gap-space-sm"><button aria-label="Search Catalog or Scan Barcode" class="w-11 h-11 rounded-xl bg-surface-container-high hover:bg-surface-variant flex items-center justify-center text-on-surface-variant hover:text-on-surface transition-colors"><span class="material-symbols-outlined text-[20px]">barcode_scanner</span></button><button aria-label="Cashier Profile" class="flex items-center gap-space-xs pl-space-xs rounded-full hover:bg-surface-container-high transition-colors"><img alt="Profile" class="w-8 h-8 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida/AEtjO1X3q5n5Qeu54RKL6HFUarPePU4H-knzl_0DUp00Acwg2lCP89sAGszi0XxE6gh7gBfEKHYQ-uRboJ0WYSZ9U66mHr6sm0r2blBLnGYC19yRTyzfPG9suQXNwVGy2a5baLj-nXWqq1Kh6XUxgax5pno4rwIrCenUEekhaM7oKEUneV11coG4QLFhuG4QYMp8Akjzq6s7YLS3g6I_UW0LRn2JrRzlnxhpJLaF_QIb9xhHcA"/></button></div></div></header><main class="flex-1 w-full bg-surface pt-16 pb-28 min-h-screen"><div class="flex flex-col w-full">
<div class="px-margin space-y-space-md pb-space-xl">
<div class="relative overflow-hidden rounded-xl bg-surface-container-high p-space-md shadow-md">
<div class="absolute -right-12 -top-12 w-36 h-36 rounded-full bg-primary-container/10 blur-2xl pointer-events-none"></div>
<div class="flex items-start justify-between gap-space-sm mb-space-sm">
<div class="flex flex-col min-w-0">
<span class="font-headline-md text-headline-md text-on-surface font-bold tracking-tight">Buka Kasir</span>
<span class="font-label-sm text-label-sm text-on-surface-variant flex items-center gap-1 mt-0.5">
<span class="material-symbols-outlined text-[14px] text-primary">store</span>
            Terminal 04 • Kopi Kinetic Outlet #01
          </span>
</div>
<div class="flex items-center gap-1.5 px-space-sm py-1 rounded-full bg-tertiary-container/20 text-tertiary-fixed shadow-sm">
<span class="w-2 h-2 rounded-full bg-tertiary-fixed-dim animate-pulse"></span>
<span class="font-label-sm text-label-sm uppercase tracking-wider font-bold">Laci Terkunci</span>
</div>
</div>
<div class="flex items-center gap-space-sm p-space-sm rounded-lg bg-surface-container-low">
<img alt="Budi Santoso Avatar" class="w-11 h-11 rounded-lg object-cover" data-alt="Close up portrait photograph of an Indonesian male coffee shop head cashier named Budi wearing a dark barista apron with a warm welcoming slight smile in a modern cyber neon café interior with low dramatic cyan and deep indigo lighting." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDudbDDhU9EDHnOcynZYCrjTo8EZMub7azLJ_Q7mjLsVmKEFBVb6_-cHkyWa4f-Eb7wvJO4xWNYfvk2rUH0e6DqoD_guF8z4e4pImhWkvfCq0XzgSd9kbmYBD5vwIebO_dDEexd827i-NqzlWm_XjBiCp-N4ClJsQDpLDKVJ0_-U93Li2Wz_RhQSw_99tqPBsNOUpdbaEN2FYliVLtbEggdX4lEUJ0D16oGGchQa-_U"/>
<div class="flex flex-col flex-1 min-w-0">
<div class="flex items-center justify-between">
<span class="font-label-lg text-label-lg font-bold text-on-surface truncate">Budi Santoso</span>
<span class="font-label-sm text-label-sm text-primary uppercase font-bold">Kasir Utama</span>
</div>
<span class="font-body-sm text-body-sm text-on-surface-variant flex items-center gap-1 mt-0.5">
<span class="material-symbols-outlined text-[13px] text-secondary">wb_sunny</span>
            Shift Pagi (07:00 - 15:00 WIB)
          </span>
</div>
</div>
</div>
<div class="flex flex-col rounded-xl bg-surface-container p-space-md shadow-md space-y-space-md">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-primary text-[20px]">account_balance_wallet</span>
<span class="font-label-lg text-label-lg font-bold text-on-surface">Modal Awal Kas (Cash Float)</span>
</div>
<span class="font-label-sm text-label-sm text-on-surface-variant">Laci Tunai Fisik</span>
</div>
<div class="flex flex-col items-center justify-center p-space-md rounded-xl bg-surface-container-lowest shadow-inner relative overflow-hidden">
<div class="absolute inset-x-0 top-0 h-0.5 bg-gradient-to-r from-transparent via-primary-container to-transparent opacity-60"></div>
<span class="font-label-sm text-label-sm text-on-surface-variant tracking-wider uppercase mb-1">Total Nominal Masuk</span>
<div class="flex items-baseline gap-1">
<span class="font-numeric-display text-headline-md font-bold text-primary">Rp</span>
<span class="font-numeric-display text-numeric-display text-primary tracking-tight font-extrabold" id="cash-display">200.000</span>
</div>
</div>
<div class="grid grid-cols-4 gap-space-xs">
<button class="flex flex-col items-center justify-center py-2.5 px-1 rounded-lg bg-surface-container-high hover:bg-surface-variant active:scale-95 transition-all text-on-surface" id="btn-add-50" type="button">
<span class="font-label-sm text-label-sm text-on-surface-variant">+50k</span>
<span class="font-label-md text-label-md font-bold">+50.000</span>
</button>
<button class="flex flex-col items-center justify-center py-2.5 px-1 rounded-lg bg-surface-container-high hover:bg-surface-variant active:scale-95 transition-all text-on-surface" id="btn-add-100" type="button">
<span class="font-label-sm text-label-sm text-on-surface-variant">+100k</span>
<span class="font-label-md text-label-md font-bold">+100.000</span>
</button>
<button class="flex flex-col items-center justify-center py-2.5 px-1 rounded-lg bg-secondary-container/40 hover:bg-secondary-container/60 active:scale-95 transition-all text-secondary-fixed" id="btn-default" type="button">
<span class="material-symbols-outlined text-[16px]">restart_alt</span>
<span class="font-label-md text-label-md font-bold">Standar</span>
</button>
<button class="flex flex-col items-center justify-center py-2.5 px-1 rounded-lg bg-surface-container-high hover:bg-surface-variant active:scale-95 transition-all text-error" id="btn-reset" type="button">
<span class="material-symbols-outlined text-[16px]">backspace</span>
<span class="font-label-md text-label-md font-bold">Nol</span>
</button>
</div>
<div class="rounded-lg bg-surface-container-low p-space-sm space-y-space-sm">
<button class="w-full flex items-center justify-between text-left" id="toggle-denom" type="button">
<span class="font-label-md text-label-md text-on-surface flex items-center gap-1.5 font-bold">
<span class="material-symbols-outlined text-primary text-[18px]">payments</span>
            Rincian Uang Kertas &amp; Koin
          </span>
<div class="flex items-center gap-1">
<span class="font-label-sm text-label-sm text-primary font-bold">5 Pecahan</span>
<span class="material-symbols-outlined text-[18px] text-on-surface-variant transition-transform" id="denom-icon">expand_more</span>
</div>
</button>
<div class="space-y-space-xs pt-space-xs" id="denom-list">
<div class="flex items-center justify-between p-2 rounded-lg bg-surface-container">
<div class="flex items-center gap-2">
<span class="w-7 h-5 rounded bg-error-container/40 text-error flex items-center justify-center font-label-sm text-label-sm font-bold">100k</span>
<span class="font-body-sm text-body-sm text-on-surface">Pecahan Rp 100.000</span>
</div>
<div class="flex items-center gap-2">
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">-</button>
<span class="font-label-md text-label-md font-bold text-on-surface w-4 text-center">1</span>
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">+</button>
</div>
</div>
<div class="flex items-center justify-between p-2 rounded-lg bg-surface-container">
<div class="flex items-center gap-2">
<span class="w-7 h-5 rounded bg-secondary-container/40 text-secondary flex items-center justify-center font-label-sm text-label-sm font-bold">50k</span>
<span class="font-body-sm text-body-sm text-on-surface">Pecahan Rp 50.000</span>
</div>
<div class="flex items-center gap-2">
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">-</button>
<span class="font-label-md text-label-md font-bold text-on-surface w-4 text-center">1</span>
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">+</button>
</div>
</div>
<div class="flex items-center justify-between p-2 rounded-lg bg-surface-container">
<div class="flex items-center gap-2">
<span class="w-7 h-5 rounded bg-primary-container/20 text-primary flex items-center justify-center font-label-sm text-label-sm font-bold">20k</span>
<span class="font-body-sm text-body-sm text-on-surface">Pecahan Rp 20.000</span>
</div>
<div class="flex items-center gap-2">
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">-</button>
<span class="font-label-md text-label-md font-bold text-on-surface w-4 text-center">2</span>
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">+</button>
</div>
</div>
<div class="flex items-center justify-between p-2 rounded-lg bg-surface-container">
<div class="flex items-center gap-2">
<span class="w-7 h-5 rounded bg-tertiary-container/30 text-tertiary flex items-center justify-center font-label-sm text-label-sm font-bold">10k</span>
<span class="font-body-sm text-body-sm text-on-surface">Pecahan Rp 10.000</span>
</div>
<div class="flex items-center gap-2">
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">-</button>
<span class="font-label-md text-label-md font-bold text-on-surface w-4 text-center">1</span>
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">+</button>
</div>
</div>
<div class="flex items-center justify-between p-2 rounded-lg bg-surface-container">
<div class="flex items-center gap-2">
<span class="w-7 h-5 rounded bg-surface-container-high text-on-surface-variant flex items-center justify-center font-label-sm text-label-sm font-bold">1k</span>
<span class="font-body-sm text-body-sm text-on-surface">Koin Rp 1.000</span>
</div>
<div class="flex items-center gap-2">
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">-</button>
<span class="font-label-md text-label-md font-bold text-on-surface w-4 text-center">0</span>
<button class="w-6 h-6 rounded bg-surface-container-high text-on-surface flex items-center justify-center active:scale-95" type="button">+</button>
</div>
</div>
</div>
</div>
</div>
<div class="rounded-xl bg-surface-container p-space-md space-y-space-sm shadow-md">
<div class="flex items-center justify-between">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-primary text-[20px]">tune</span>
<span class="font-label-lg text-label-lg font-bold text-on-surface">Kesiapan Hardware &amp; Sistem</span>
</div>
<span class="font-label-sm text-label-sm text-primary font-bold">4/4 Siap</span>
</div>
<div class="grid grid-cols-1 gap-space-xs">
<div class="flex items-center justify-between p-2.5 rounded-lg bg-surface-container-low">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded-lg bg-surface-container flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[18px]">lock_open</span>
</div>
<div class="flex flex-col min-w-0">
<span class="font-label-md text-label-md text-on-surface font-semibold truncate">Laci Kas RJ11</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">Terhubung • Siap Pop</span>
</div>
</div>
<span class="material-symbols-outlined text-primary text-[20px]">check_circle</span>
</div>
<div class="flex items-center justify-between p-2.5 rounded-lg bg-surface-container-low">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded-lg bg-surface-container flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[18px]">print</span>
</div>
<div class="flex flex-col min-w-0">
<span class="font-label-md text-label-md text-on-surface font-semibold truncate">Printer Struk 80mm</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">Bluetooth Online • Roll Penuh</span>
</div>
</div>
<span class="material-symbols-outlined text-primary text-[20px]">check_circle</span>
</div>
<div class="flex items-center justify-between p-2.5 rounded-lg bg-surface-container-low">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded-lg bg-surface-container flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[18px]">qr_code_scanner</span>
</div>
<div class="flex flex-col min-w-0">
<span class="font-label-md text-label-md text-on-surface font-semibold truncate">EDC &amp; QRIS Statis</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">Merchant Aktif • Siap Scan</span>
</div>
</div>
<span class="material-symbols-outlined text-primary text-[20px]">check_circle</span>
</div>
<div class="flex items-center justify-between p-2.5 rounded-lg bg-surface-container-low">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded-lg bg-surface-container flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[18px]">cloud_sync</span>
</div>
<div class="flex flex-col min-w-0">
<span class="font-label-md text-label-md text-on-surface font-semibold truncate">Cloud POS Sync</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">LAN Stabil • Ping 12ms</span>
</div>
</div>
<span class="material-symbols-outlined text-primary text-[20px]">check_circle</span>
</div>
</div>
</div>
<div class="rounded-xl bg-surface-container p-space-md space-y-space-md shadow-md">
<div class="space-y-1">
<label class="font-label-md text-label-md text-on-surface font-semibold flex items-center gap-1.5" for="shift-notes">
<span class="material-symbols-outlined text-primary text-[18px]">edit_note</span>
          Catatan Pembukaan Shift
        </label>
<span class="font-body-sm text-body-sm text-on-surface-variant">Tambahkan catatan kondisi awal shift (opsional)</span>
</div>
<div class="relative">
<textarea class="w-full bg-surface-container-lowest text-on-surface rounded-xl p-space-sm font-body-sm text-body-sm placeholder:text-on-surface-variant/50 focus:outline-none focus:bg-surface-container-low resize-none transition-colors" id="shift-notes" placeholder="cth: Uang kembalian 5rb terbatas, cup reguler sisa 40 pcs..." rows="2"></textarea>
</div>
<div class="flex items-center justify-between p-space-sm rounded-lg bg-surface-container-low">
<div class="flex flex-col">
<span class="font-label-md text-label-md font-semibold text-on-surface">Cetak Bukti Buka Kasir</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">Cetak slip modal awal otomatis</span>
</div>
<button class="w-12 h-6 rounded-full bg-primary-container p-0.5 flex items-center justify-end transition-colors shadow-sm" id="toggle-print" type="button">
<div class="w-5 h-5 rounded-full bg-on-primary transform transition-transform" id="toggle-thumb"></div>
</button>
</div>
</div>
<div class="flex flex-col gap-space-sm pt-space-xs">
<button class="w-full h-14 rounded-xl bg-primary-container hover:bg-primary text-on-primary font-bold active:scale-95 transition-all flex items-center justify-between px-space-lg shadow-[0_0_20px_rgba(0,229,153,0.25)]" id="btn-submit-open" type="button">
<div class="flex items-center gap-space-xs">
<span class="material-symbols-outlined text-[24px]">key</span>
<span class="font-label-lg text-label-lg uppercase tracking-wider font-extrabold">Buka Kasir &amp; Mulai</span>
</div>
<span class="material-symbols-outlined text-[22px]">arrow_forward</span>
</button>
<button class="w-full h-12 rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface-variant font-label-md text-label-md font-semibold active:scale-95 transition-all flex items-center justify-center gap-1.5" type="button">
<span class="material-symbols-outlined text-[18px]">arrow_back</span>
        Batal / Kembali ke Dashboard
      </button>
</div>
</div>
</div>
<script>
  (function () {
    let currentAmount = 200000;
    const displayEl = document.getElementById('cash-display');
    const btn50 = document.getElementById('btn-add-50');
    const btn100 = document.getElementById('btn-add-100');
    const btnDefault = document.getElementById('btn-default');
    const btnReset = document.getElementById('btn-reset');
    const toggleDenom = document.getElementById('toggle-denom');
    const denomList = document.getElementById('denom-list');
    const denomIcon = document.getElementById('denom-icon');
    const togglePrint = document.getElementById('toggle-print');
    const toggleThumb = document.getElementById('toggle-thumb');
    let printEnabled = true;

    function formatRupiah(num) {
      return num.toLocaleString('id-ID');
    }

    function updateDisplay() {
      if (displayEl) {
        displayEl.innerText = formatRupiah(currentAmount);
      }
    }

    if (btn50) {
      btn50.addEventListener('click', function () {
        currentAmount += 50000;
        updateDisplay();
      });
    }

    if (btn100) {
      btn100.addEventListener('click', function () {
        currentAmount += 100000;
        updateDisplay();
      });
    }

    if (btnDefault) {
      btnDefault.addEventListener('click', function () {
        currentAmount = 200000;
        updateDisplay();
      });
    }

    if (btnReset) {
      btnReset.addEventListener('click', function () {
        currentAmount = 0;
        updateDisplay();
      });
    }

    if (toggleDenom && denomList && denomIcon) {
      toggleDenom.addEventListener('click', function () {
        const isHidden = denomList.classList.toggle('hidden');
        denomIcon.style.transform = isHidden ? 'rotate(180deg)' : 'rotate(0deg)';
      });
    }

    if (togglePrint && toggleThumb) {
      togglePrint.addEventListener('click', function () {
        printEnabled = !printEnabled;
        if (printEnabled) {
          togglePrint.classList.remove('bg-surface-variant');
          togglePrint.classList.add('bg-primary-container');
          toggleThumb.classList.remove('bg-on-surface-variant');
          toggleThumb.classList.add('bg-on-primary');
          toggleThumb.style.transform = 'translateX(0px)';
        } else {
          togglePrint.classList.remove('bg-primary-container');
          togglePrint.classList.add('bg-surface-variant');
          toggleThumb.classList.remove('bg-on-primary');
          toggleThumb.classList.add('bg-on-surface-variant');
          toggleThumb.style.transform = 'translateX(-24px)';
        }
      });
    }

    const btnSubmit = document.getElementById('btn-submit-open');
    if (btnSubmit) {
      btnSubmit.addEventListener('click', function () {
        btnSubmit.classList.add('scale-95');
        setTimeout(function () {
          btnSubmit.classList.remove('scale-95');
        }, 150);
      });
    }
  })();
</script></main><nav class="fixed bottom-0 w-full z-50 pb-safe bg-surface-container-lowest/95 backdrop-blur-xl shadow-[0_-8px_24px_rgba(0,0,0,0.45)]" data-active-classes="bg-surface-container text-primary font-bold"><div class="px-margin pt-space-xs pb-space-sm flex items-center justify-between gap-space-sm"><button class="flex items-center gap-space-xs px-space-md py-space-sm h-14 rounded-xl bg-surface-container-high hover:bg-surface-variant text-on-surface-variant hover:text-on-surface transition-all active:scale-95"><span class="material-symbols-outlined text-[20px]">pause_circle</span><span class="font-label-md text-label-md">Hold</span></button><div class="flex-1 flex items-center justify-between px-space-md h-14 rounded-xl bg-surface-container-low"><div class="flex flex-col"><span class="font-label-sm text-label-sm text-on-surface-variant">Active Ticket</span><span class="font-label-lg text-label-lg text-on-surface font-semibold">3 items</span></div><span class="font-headline-md text-headline-md text-primary font-bold">$24.50</span></div><button class="flex items-center justify-center gap-space-xs px-space-lg h-14 rounded-xl bg-primary-container hover:bg-primary text-on-primary font-bold active:scale-95 transition-all shadow-[0_0_16px_rgba(0,229,153,0.3)]"><span class="font-label-lg text-label-lg uppercase tracking-wider font-extrabold">Pay</span><span class="material-symbols-outlined text-[22px]">arrow_forward</span></button></div><div class="flex items-center justify-around h-14 px-margin bg-surface-container-lowest"><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="catalog" href="#"><span class="material-symbols-outlined text-[22px]">grid_view</span><span class="font-label-sm text-label-sm">Register</span></a><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="tickets" href="#"><span class="material-symbols-outlined text-[22px]">receipt_long</span><span class="font-label-sm text-label-sm">Tickets</span></a><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="activity" href="#"><span class="material-symbols-outlined text-[22px]">history</span><span class="font-label-sm text-label-sm">History</span></a><a class="flex flex-col items-center justify-center w-16 h-12 rounded-lg text-on-surface-variant transition-colors hover:text-on-surface" data-path="more-menu" href="#"><span class="material-symbols-outlined text-[22px]">menu</span><span class="font-label-sm text-label-sm">Menu</span></a></div></nav></body></html>