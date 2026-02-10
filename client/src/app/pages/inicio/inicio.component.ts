import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateService } from '@ngx-translate/core';
import { Subject, takeUntil } from 'rxjs';

// Interfaces para el tipado
interface LanguageText {
  es: string;
  en: string;
}

interface Hero {
  title: LanguageText;
  subtitle: LanguageText;
  cta: {
    text: LanguageText;
    link: string;
  };
}

interface Statistics {
  value: string;
  label: LanguageText;
}

interface Feature {
  id: string;
  icon: string;
  title: LanguageText;
  description: LanguageText;
}

interface Section {
  id: string;
  title: LanguageText;
  description: LanguageText;
  image: string;
  link: {
    text: LanguageText;
    route: string;
  };
}

interface HomeConfig {
  pages: {
    home: {
      hero: Hero;
      sections: Section[];
      features: Feature[];
      statistics: {
        title: LanguageText;
        items: Statistics[];
      };
    };
  };
}

@Component({
  selector: 'app-inicio',
  templateUrl: './inicio.component.html',
  standalone: true,
  imports: [CommonModule, RouterModule],
})
export class InicioComponent implements OnInit {
  private destroy$ = new Subject<void>();
  private translateService = inject(TranslateService);

  currentLang: string = 'es';

  config: HomeConfig = {
    pages: {
      home: {
        hero: {
          title: {
            es: 'Comprá más inteligente',
            en: 'Shop smarter',
          },
          subtitle: {
            es: 'Compará precios en tiempo real de los principales supermercados',
            en: 'Compare real-time prices from major supermarkets',
          },
          cta: {
            text: {
              es: 'Comenzar a comparar',
              en: 'Start comparing',
            },
            link: '/comparador-de-precios',
          },
        },
        sections: [
          {
            id: 'price-comparison',
            title: {
              es: 'Comparador de Precios',
              en: 'Price Comparison',
            },
            description: {
              es: 'Comprá inteligente a través de nuestro comparador de precios. Encontrá las mejores ofertas en productos de la canasta básica comparando precios entre diferentes supermercados.',
              en: 'Shop smart with our price comparison tool. Find the best deals on basic basket products by comparing prices between different supermarkets.',
            },
            image:
              'https://plus.unsplash.com/premium_photo-1661492010505-855abf9540b7?q=80&w=2008&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            link: {
              text: {
                es: 'Ir al comparador',
                en: 'Go to comparator',
              },
              route: '/comparador-de-precios',
            },
          },
          {
            id: 'supermarkets',
            title: {
              es: 'Supermercados Adheridos',
              en: 'Participating Supermarkets',
            },
            description: {
              es: 'Conocé los supermercados que participan en nuestra plataforma. Encontrá información detallada sobre sucursales, horarios y servicios disponibles.',
              en: 'Learn about the supermarkets participating in our platform. Find detailed information about branches, schedules and available services.',
            },
            image:
              'https://plus.unsplash.com/premium_photo-1681487818956-b61f40077d3b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            link: {
              text: {
                es: 'Ver supermercados',
                en: 'View supermarkets',
              },
              route: '/supermercados',
            },
          },
          {
            id: 'shopping-cart',
            title: {
              es: 'Carrito de Compras',
              en: 'Shopping Cart',
            },
            description: {
              es: 'Armá tu lista de compras y compará precios entre diferentes supermercados para encontrar la mejor opción.',
              en: 'Create your shopping list and compare prices between different supermarkets to find the best option.',
            },
            image:
              'https://plus.unsplash.com/premium_photo-1683121938935-118d0a16a469?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',

            link: {
              text: {
                es: 'Crear carrito',
                en: 'Create cart',
              },
              route: '/carrito',
            },
          },
          {
            id: 'categories',
            title: {
              es: 'Categorías de Productos',
              en: 'Product Categories',
            },
            description: {
              es: 'Explorá nuestra amplia variedad de productos organizados por categorías para facilitar tu búsqueda.',
              en: 'Explore our wide variety of products organized by categories to facilitate your search.',
            },
            image:
              'https://plus.unsplash.com/premium_photo-1664305032567-2c460e29dec1?q=80&w=1968&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            link: {
              text: {
                es: 'Ver categorías',
                en: 'View categories',
              },
              route: '/categorias',
            },
          },
        ],
        features: [
          {
            id: 'daily-updates',
            icon: 'update',
            title: {
              es: 'Actualización Diaria',
              en: 'Daily Updates',
            },
            description: {
              es: 'Precios actualizados todos los días para mantener la información precisa',
              en: 'Prices updated every day to maintain accurate information',
            },
          },
          {
            id: 'easy-comparison',
            icon: 'compare',
            title: {
              es: 'Comparación Sencilla',
              en: 'Easy Comparison',
            },
            description: {
              es: 'Interfaz intuitiva para comparar precios entre diferentes supermercados',
              en: 'Intuitive interface to compare prices between different supermarkets',
            },
          },
          {
            id: 'location-based',
            icon: 'location_on',
            title: {
              es: 'Basado en Ubicación',
              en: 'Location Based',
            },
            description: {
              es: 'Encontrá los mejores precios en tu zona',
              en: 'Find the best prices in your area',
            },
          },
        ],
        statistics: {
          title: {
            es: 'Números que Importan',
            en: 'Numbers that Matter',
          },
          items: [
            {
              value: '1000+',
              label: {
                es: 'Productos',
                en: 'Products',
              },
            },
            {
              value: '50+',
              label: {
                es: 'Supermercados',
                en: 'Supermarkets',
              },
            },
            {
              value: '200+',
              label: {
                es: 'Sucursales',
                en: 'Branches',
              },
            },
          ],
        },
      },
    },
  };

  constructor() {}

  ngOnInit(): void {
    // Suscribirse a los cambios de idioma
    this.translateService.onLangChange
      .pipe(takeUntil(this.destroy$))
      .subscribe((event) => {
        this.currentLang = event.lang;
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  // Método para obtener las secciones
  get sections(): Section[] {
    return this.config.pages.home.sections;
  }

  // Método para obtener las características
  get features(): Feature[] {
    return this.config.pages.home.features;
  }

  // Método para obtener las estadísticas
  get statistics(): Statistics[] {
    return this.config.pages.home.statistics.items;
  }

  getText(text: LanguageText): string {
    return text[this.currentLang as keyof LanguageText] || '';
  }
}
