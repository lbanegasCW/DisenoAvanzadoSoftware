import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

interface Feature {
  icon: string;
  title: string;
  description: string;
}

interface Section {
  title: string;
  description: string;
  image: string;
  link: {
    text: string;
    route: string;
  };
}

@Component({
  selector: 'app-inicio',
  templateUrl: './inicio.component.html',
  standalone: true,
  imports: [CommonModule, RouterModule],
})
export class InicioComponent {
  heroTitle = $localize`:@@inicio.hero_title:Comprá más inteligente`;
  heroSubtitle = $localize`:@@inicio.hero_subtitle:Compará precios en tiempo real de los principales supermercados`;
  heroCta = $localize`:@@inicio.hero_cta:Comenzar a comparar`;
  heroCtaLink = '/comparador';

  features: Feature[] = [
    {
      icon: 'update',
      title: $localize`:@@inicio.feature_daily_title:Actualización Diaria`,
      description: $localize`:@@inicio.feature_daily_desc:Precios actualizados todos los días para mantener la información precisa`,
    },
    {
      icon: 'compare',
      title: $localize`:@@inicio.feature_comparison_title:Comparación Sencilla`,
      description: $localize`:@@inicio.feature_comparison_desc:Interfaz intuitiva para comparar precios entre diferentes supermercados`,
    },
    {
      icon: 'location_on',
      title: $localize`:@@inicio.feature_location_title:Basado en Ubicación`,
      description: $localize`:@@inicio.feature_location_desc:Encontrá los mejores precios en tu zona`,
    },
  ];

  sections: Section[] = [
    {
      title: $localize`:@@inicio.section_comparador_title:Comparador de Precios`,
      description: $localize`:@@inicio.section_comparador_desc:Comprá inteligente a través de nuestro comparador de precios. Encontrá las mejores ofertas en productos de la canasta básica comparando precios entre diferentes supermercados.`,
      image:
        'https://plus.unsplash.com/premium_photo-1661492010505-855abf9540b7?q=80&w=2008&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      link: {
        text: $localize`:@@inicio.section_comparador_link:Ir al comparador`,
        route: '/comparador',
      },
    },
    {
      title: $localize`:@@inicio.section_supermercados_title:Supermercados Adheridos`,
      description: $localize`:@@inicio.section_supermercados_desc:Conocé los supermercados que participan en nuestra plataforma. Encontrá información detallada sobre sucursales, horarios y servicios disponibles.`,
      image:
        'https://plus.unsplash.com/premium_photo-1681487818956-b61f40077d3b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      link: {
        text: $localize`:@@inicio.section_supermercados_link:Ver supermercados`,
        route: '/supermercados',
      },
    },
    {
      title: $localize`:@@inicio.section_carrito_title:Carrito de Compras`,
      description: $localize`:@@inicio.section_carrito_desc:Armá tu lista de compras y compará precios entre diferentes supermercados para encontrar la mejor opción.`,
      image:
        'https://plus.unsplash.com/premium_photo-1683121938935-118d0a16a469?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      link: {
        text: $localize`:@@inicio.section_carrito_link:Crear carrito`,
        route: '/carrito',
      },
    },
    {
      title: $localize`:@@inicio.section_categorias_title:Categorías de Productos`,
      description: $localize`:@@inicio.section_categorias_desc:Explorá nuestra amplia variedad de productos organizados por categorías para facilitar tu búsqueda.`,
      image:
        'https://plus.unsplash.com/premium_photo-1664305032567-2c460e29dec1?q=80&w=1968&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      link: {
        text: $localize`:@@inicio.section_categorias_link:Ver categorías`,
        route: '/categorias',
      },
    },
  ];
}
