const faqs = [
  {
    q: 'Does BeforeUScroll read what I do in other apps?',
    a: 'No. It uses Apple Screen Time APIs and Apple-provided tokens for selected apps. It does not read messages, feeds, browsing content, or your screen.'
  },
  {
    q: 'What happens when my Flame reaches zero?',
    a: 'Protection returns automatically for the apps you chose. You can recharge again with Scripture or prayer.'
  },
  {
    q: 'Can it block adult content inside social apps?',
    a: 'BeforeUScroll can shield selected apps entirely. Web Guard can help with adult websites where iOS supports filtering, but it cannot inspect content inside third-party app feeds.'
  },
  {
    q: 'Is this a Bible quiz app?',
    a: 'No. The questions are there to help you remember Scripture before you enter apps designed to pull your attention away'
  }
];

export function FAQ() {
  return (
    <section className="px-4 py-20 md:px-8 md:py-28">
      <div className="mx-auto max-w-4xl">
        <div className="mb-10 text-center">
          <p className="mb-3 text-sm font-black uppercase tracking-[0.26em] text-gold">FAQ</p>
          <h2 className="text-4xl font-black tracking-[-0.04em] text-cream md:text-6xl">Clear by design.</h2>
        </div>
        <div className="space-y-4">
          {faqs.map((faq) => (
            <details key={faq.q} className="glass group rounded-[1.6rem] p-6 open:bg-white/10">
              <summary className="cursor-pointer list-none text-xl font-black text-cream marker:hidden">{faq.q}</summary>
              <p className="mt-4 font-bold leading-7 text-cream/60">{faq.a}</p>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}
