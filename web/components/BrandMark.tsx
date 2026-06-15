import Image from 'next/image';
import clsx from 'clsx';

const sizeMap = {
  sm: 'h-8 w-8',
  md: 'h-12 w-12',
  lg: 'h-20 w-20',
  xl: 'h-32 w-32 md:h-40 md:w-40'
};

export function BrandMark({ size = 'md', glow = true, className }: { size?: keyof typeof sizeMap; glow?: boolean; className?: string }) {
  return (
    <div className={clsx('relative inline-flex shrink-0 items-center justify-center', sizeMap[size], className)} aria-label="BeforeUScroll Flame">
      {glow && <span className="absolute inset-0 rounded-full bg-ember/35 blur-2xl" aria-hidden />}
      <Image src="/brand/flame.png" alt="BeforeUScroll Flame" fill sizes="160px" className="relative object-contain" priority={size === 'xl'} />
    </div>
  );
}
