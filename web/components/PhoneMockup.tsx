import Image from 'next/image';
import clsx from 'clsx';

export function PhoneMockup({ src, alt, className, priority = false }: { src: string; alt: string; className?: string; priority?: boolean }) {
  return (
    <div className={clsx('phone-frame overflow-hidden', className)}>
      <Image src={src} alt={alt} width={520} height={1126} priority={priority} className="h-auto w-full" />
    </div>
  );
}
