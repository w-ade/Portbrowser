export default function Home() {
  return (
    <main className="flex flex-1 items-center justify-center px-6">
      <div className="flex flex-col items-center gap-3 text-center">
        <h1 className="text-2xl font-semibold tracking-tight">Port Browser</h1>
        <p className="max-w-xs text-sm text-black/50 dark:text-white/50">
          A focused macOS window for previewing local websites at iPhone
          viewport sizes.
        </p>
        <span className="mt-2 text-xs uppercase tracking-widest text-black/30 dark:text-white/30">
          Coming soon
        </span>
      </div>
    </main>
  );
}
