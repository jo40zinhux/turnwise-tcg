import { Component, input } from '@angular/core';

@Component({
  selector: 'tw-empty-state',
  template: `
    <div class="empty surface">
      <h3>{{ title() }}</h3>
      <p class="muted">{{ body() }}</p>
      <ng-content />
    </div>
  `,
  styles: `
    .empty { display: grid; gap: 8px; justify-items: start; }
  `,
})
export class EmptyStateComponent {
  readonly title = input.required<string>();
  readonly body = input.required<string>();
}
