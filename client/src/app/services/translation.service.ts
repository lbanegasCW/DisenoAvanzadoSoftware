import { Injectable } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

@Injectable({ providedIn: 'root' })
export class TranslationService {
  constructor(private translate: TranslateService) {
    const defaultLang = 'es';
    translate.addLangs(['en', 'es']);
    translate.setDefaultLang(defaultLang);
  }

  switchLanguage(lang: string) {
    this.translate.use(lang);
  }
}
