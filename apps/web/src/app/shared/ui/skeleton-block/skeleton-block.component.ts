import { Component, input } from '@angular/core';

@Component({
  selector: 'tw-skeleton',
  template: `<div class="sk" [style.height]="height()"></div>`,
  styles: `
    .sk {
      border-radius: 16px;
      background: linear-gradient(90deg, #1e1e1e, #262626, #1e1e1e);
      background-size: 200% 100%;
      animation: pulse 1.2s ease-out infinite;
    }
    @media (prefers-reduced-motion: reduce) {
      .sk { animation: none; background: #1e1e1e; }
    }
    @keyframes pulse {
      from { background-position: 100% 0; }
      to { background-position: -100% 0; }
    }
  `,
})
export class SkeletonBlockComponent {
  readonly height = input('72px');
}
