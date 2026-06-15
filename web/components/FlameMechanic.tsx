'use client';

import { motion } from 'framer-motion';
import { SectionHeading } from './SectionHeading';
import { BrandMark } from './BrandMark';

export function FlameMechanic() {
  return (
    <section className="relative overflow-hidden px-4 py-20 md:px-8 md:py-28">
      <div className="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_center,rgba(255,106,61,.18),transparent_58%)]" />
      <div className="mx-auto max-w-6xl">
        <SectionHeading eyebrow="The Flame" title="When it burns, you have intentional time. When it dies, apps lock." />
        <div className="glass grid items-center gap-10 overflow-hidden rounded-[3rem] p-8 md:grid-cols-[.9fr_1.1fr] md:p-12">
          <motion.div className="relative mx-auto flex aspect-square w-full max-w-sm items-center justify-center rounded-full" animate={{ y: [0, -8, 0] }} transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}>
            <span className="absolute inset-8 rounded-full bg-ember/20 blur-3xl" />
            <BrandMark size="xl" className="z-10" />
          </motion.div>
          <div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="rounded-[2rem] bg-black/20 p-5 ring-1 ring-white/10">
                <p className="text-sm font-black uppercase tracking-[0.22em] text-gold">Scripture</p>
                <h3 className="mt-3 text-3xl font-black text-cream">Read +10</h3>
                <p className="mt-2 font-bold leading-7 text-cream/55">Answer five questions to remember the verse before apps open.</p>
              </div>
              <div className="rounded-[2rem] bg-black/20 p-5 ring-1 ring-white/10">
                <p className="text-sm font-black uppercase tracking-[0.22em] text-gold">Prayer</p>
                <h3 className="mt-3 text-3xl font-black text-cream">Pray +1/min</h3>
                <p className="mt-2 font-bold leading-7 text-cream/55">Protected apps stay locked while you pray.</p>
              </div>
            </div>
            <p className="mt-8 text-xl font-extrabold leading-9 text-cream/70">The Flame burns automatically. No confusing start button. No hidden timer screen. Just a clear visual of how much intentional time remains.</p>
          </div>
        </div>
      </div>
    </section>
  );
}
