"use client";

import { useState } from "react";

// A half-filled circle in the top-right corner. The page follows the device
// until this is clicked; then it flips to the other theme and remembers the
// choice (localStorage "theme"). The saved choice is applied before paint by
// the inline script in layout.tsx, so there is no flash on load.
//
// Each tap spins the circle half a turn, so the filled half swings to the
// other side, with a little overshoot to settle; the button dips while pressed.
// Reduced motion keeps the swap and drops the spin.

const KEY = "theme";

function current(): "light" | "dark" {
  const set = document.documentElement.dataset.theme;
  if (set === "light" || set === "dark") return set;
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

export default function ThemeToggle() {
  // half-turns taken; only ever grows, so every tap spins the same way
  const [turns, setTurns] = useState(0);
  const flip = () => {
    setTurns((t) => t + 1);
    const next = current() === "dark" ? "light" : "dark";
    document.documentElement.dataset.theme = next;
    try {
      localStorage.setItem(KEY, next);
    } catch {
      /* private mode: still flips, just isn't remembered */
    }
  };

  return (
    <button
      type="button"
      onClick={flip}
      aria-label="Toggle dark mode"
      className="fixed top-4 right-4 z-10 grid size-7 place-items-center rounded-full text-[#9A9A9C] transition-[color,scale] duration-150 ease-out hover:text-foreground active:scale-90 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-current"
    >
      <svg
        viewBox="0 0 16 16"
        width="14"
        height="14"
        aria-hidden="true"
        className="transition-transform duration-500 ease-[cubic-bezier(0.34,1.56,0.64,1)] motion-reduce:transition-none"
        style={{ transform: `rotate(${turns * 180}deg)` }}
      >
        <circle cx="8" cy="8" r="6.5" fill="none" stroke="currentColor" strokeWidth="1.25" />
        <path d="M8 1.5a6.5 6.5 0 0 1 0 13z" fill="currentColor" />
      </svg>
    </button>
  );
}
