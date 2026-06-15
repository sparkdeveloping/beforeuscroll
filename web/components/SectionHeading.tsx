export function SectionHeading({ eyebrow, title, body }: { eyebrow?: string; title: string; body?: string }) {
  return (
    <div className="mx-auto mb-12 max-w-3xl text-center">
      {eyebrow && <p className="mb-4 text-sm font-black uppercase tracking-[0.26em] text-gold">{eyebrow}</p>}
      <h2 className="text-balance text-4xl font-black leading-tight tracking-[-0.04em] text-cream md:text-6xl">{title}</h2>
      {body && <p className="mx-auto mt-5 max-w-2xl text-balance text-lg font-bold leading-8 text-cream/62">{body}</p>}
    </div>
  );
}
