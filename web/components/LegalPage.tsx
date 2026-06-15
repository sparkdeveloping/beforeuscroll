import Link from 'next/link';
import { BrandMark } from './BrandMark';

export function LegalPage({ title, subtitle, children }: { title: string; subtitle?: string; children: React.ReactNode }) {
  return (
    <main className="min-h-screen px-4 py-10 md:px-8">
      <div className="mx-auto max-w-4xl">
        <Link href="/" className="mb-10 inline-flex items-center gap-3 text-cream">
          <BrandMark size="sm" glow={false} />
          <span className="font-black">BeforeUScroll</span>
        </Link>
        <section className="glass rounded-[2.5rem] p-6 md:p-10">
          <p className="mb-4 text-sm font-black uppercase tracking-[0.24em] text-gold">Legal</p>
          <h1 className="text-4xl font-black tracking-[-0.04em] text-cream md:text-6xl">{title}</h1>
          {subtitle && <p className="mt-4 text-lg font-bold leading-8 text-cream/58">{subtitle}</p>}
          <div className="prose prose-invert prose-headings:text-cream prose-p:text-cream/65 prose-li:text-cream/65 prose-a:text-gold mt-10 max-w-none prose-headings:font-black prose-p:font-semibold prose-li:font-semibold">
            {children}
          </div>
        </section>
      </div>
    </main>
  );
}
