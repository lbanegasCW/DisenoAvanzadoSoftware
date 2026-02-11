import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterModule } from '@angular/router';

interface Feature {
  icon: string;
  title: string;
  description: string;
}

interface SectionLink {
  text: string;
  route: string;
}

interface Section {
  title: string;
  description: string;
  image: string;
  link: SectionLink;
}

@Component({
  selector: 'app-inicio',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './inicio.component.html',
  styleUrl: './inicio.component.css',
})
export class InicioComponent {
  readonly heroTitle = $localize`:@@inicio.hero_title:Comprá más inteligente`;
  readonly heroSubtitle =
    $localize`:@@inicio.hero_subtitle:Compará precios en tiempo real de los principales supermercados`;
  readonly heroCta = $localize`:@@inicio.hero_cta:Comenzar a comparar`;
  readonly heroCtaLink = '/comparador';

  readonly features: Feature[] = [
    {
      icon: 'update',
      title: $localize`:@@inicio.feature_daily_title:Actualización Diaria`,
      description:
        $localize`:@@inicio.feature_daily_desc:Precios actualizados todos los días para mantener la información precisa`,
    },
    {
      icon: 'compare',
      title: $localize`:@@inicio.feature_comparison_title:Comparación Sencilla`,
      description:
        $localize`:@@inicio.feature_comparison_desc:Interfaz intuitiva para comparar precios entre diferentes supermercados`,
    },
    {
      icon: 'location_on',
      title: $localize`:@@inicio.feature_location_title:Basado en Ubicación`,
      description:
        $localize`:@@inicio.feature_location_desc:Encontrá los mejores precios en tu zona`,
    },
  ];

  readonly sections: Section[] = [
    {
      title: $localize`:@@inicio.section_comparador_title:Comparador de Precios`,
      description:
        $localize`:@@inicio.section_comparador_desc:Comprá inteligente a través de nuestro comparador de precios. Encontrá las mejores ofertas en productos de la canasta básica comparando precios entre diferentes supermercados.`,
      image:
        'https://plus.unsplash.com/premium_photo-1661492010505-855abf9540b7?q=80&w=2008&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      link: {
        text: $localize`:@@inicio.section_comparador_link:Ir al comparador`,
        route: '/comparador',
      },
    },
    {
      title: $localize`:@@inicio.section_supermercados_title:Supermercados Adheridos`,
      description:
        $localize`:@@inicio.section_supermercados_desc:Conocé los supermercados que participan en nuestra plataforma. Encontrá información detallada sobre sucursales, horarios y servicios disponibles.`,
      image:
        'https://plus.unsplash.com/premium_photo-1681487818956-b61f40077d3b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      link: {
        text: $localize`:@@inicio.section_supermercados_link:Ver supermercados`,
        route: '/supermercados',
      },
    },
  ];
}
