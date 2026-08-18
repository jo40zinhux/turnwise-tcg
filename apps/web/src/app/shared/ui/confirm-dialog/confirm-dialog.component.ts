import { ChangeDetectorRef, Component, ElementRef, inject, viewChild } from '@angular/core';

@Component({
  selector: 'tw-confirm-dialog',
  template: `
    <dialog #dialog>
      <form class="stack" style="padding: 24px" method="dialog">
        <h3>{{ title }}</h3>
        <p class="muted">{{ body }}</p>
        <div class="row">
          <button class="btn btn-surface" value="no" type="submit" data-testid="confirm-dialog-no">
            {{ cancelLabel }}
          </button>
          <button class="btn btn-danger" value="yes" type="submit" data-testid="confirm-dialog-yes">
            {{ confirmLabel }}
          </button>
        </div>
      </form>
    </dialog>
  `,
})
export class ConfirmDialogComponent {
  private readonly dialog = viewChild.required<ElementRef<HTMLDialogElement>>('dialog');
  private readonly cdr = inject(ChangeDetectorRef);
  title = 'Confirmar';
  body = '';
  confirmLabel = 'Confirmar';
  cancelLabel = 'Voltar';

  open(config: {
    title: string;
    body: string;
    confirmLabel?: string;
    cancelLabel?: string;
  }): Promise<boolean> {
    this.title = config.title;
    this.body = config.body;
    this.confirmLabel = config.confirmLabel ?? 'Confirmar';
    this.cancelLabel = config.cancelLabel ?? 'Voltar';
    this.cdr.detectChanges();
    this.dialog().nativeElement.showModal();
    return new Promise((resolve) => {
      this.dialog().nativeElement.addEventListener(
        'close',
        () => {
          resolve(this.dialog().nativeElement.returnValue === 'yes');
        },
        { once: true },
      );
    });
  }
}
