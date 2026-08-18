import { Component, input } from '@angular/core';
import { EventCapacity } from '../../../core/models/domain';

@Component({
  selector: 'tw-capacity-meter',
  template: `
    <div class="capacity" [attr.aria-label]="label()">
      <strong>{{ capacity().maxParticipants }} vagas</strong>
      <span>{{ capacity().seatedCount }} inscritos</span>
      <span>{{ capacity().available }} disponíveis</span>
      @if (capacity().waitlistCount) {
        <span>{{ capacity().waitlistCount }} na waitlist</span>
      }
    </div>
  `,
  styles: `
    .capacity {
      display: flex;
      flex-wrap: wrap;
      gap: 8px 16px;
      color: var(--table-ink-muted);
      font-size: 14px;
    }
    strong { color: var(--table-ink); font-weight: 600; }
  `,
})
export class CapacityMeterComponent {
  readonly capacity = input.required<EventCapacity>();

  label() {
    const item = this.capacity();
    return `${item.maxParticipants} vagas, ${item.seatedCount} inscritos, ${item.available} disponíveis`;
  }
}
