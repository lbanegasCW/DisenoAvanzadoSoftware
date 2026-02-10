import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ComparadorDePreciosComponent } from './comparador-de-precios.component';

describe('ComparadorDePreciosComponent', () => {
  let component: ComparadorDePreciosComponent;
  let fixture: ComponentFixture<ComparadorDePreciosComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ComparadorDePreciosComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ComparadorDePreciosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
