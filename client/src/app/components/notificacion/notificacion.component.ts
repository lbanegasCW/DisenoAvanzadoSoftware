import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

export type NotificationType = 'success' | 'error' | 'info' | 'warning';

@Component({
  selector: 'app-notification',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './notificacion.component.html',
  styleUrl: './notificacion.component.css',
})
export class NotificationComponent {
  @Input() type: NotificationType = 'info';
  @Input() title: string = '';
  @Input() message: string = '';
  @Input() show: boolean = false;
}
