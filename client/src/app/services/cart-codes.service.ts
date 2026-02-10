import { Injectable, signal, computed, effect } from '@angular/core';

const STORAGE_KEY = 'cart.codes';

@Injectable({ providedIn: 'root' })
export class CartCodesService {
  private _codes = signal<string[]>([]);

  codes = computed(() => this._codes());
  count = computed(() => this._codes().length);

  constructor() {
    try {
      const raw = sessionStorage.getItem(STORAGE_KEY);
      if (raw) this._codes.set(JSON.parse(raw));
    } catch {}

    effect(() => {
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify(this._codes()));
    });
  }

  has(code: string): boolean {
    return this._codes().includes(code);
  }

  add(code: string) {
    if (this.has(code)) return;
    this._codes.set([...this._codes(), code]);
  }

  toggle(code: string) {
    this.has(code) ? this.remove(code) : this.add(code);
  }

  remove(code: string) {
    this._codes.set(this._codes().filter(c => c !== code));
  }

  clear() {
    this._codes.set([]);
  }
}
