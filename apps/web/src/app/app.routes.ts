import { Routes } from '@angular/router';
import { authGuard, guestOnlyGuard, storeAdminGuard } from './core/guards/auth.guard';
import { PublicLayoutComponent } from './layouts/public-layout.component';
import { StoreLayoutComponent } from './layouts/store-layout.component';

export const routes: Routes = [
  {
    path: '',
    component: PublicLayoutComponent,
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./features/auth/home.page').then((m) => m.HomePageComponent),
      },
      {
        path: 'login',
        canActivate: [guestOnlyGuard],
        loadComponent: () =>
          import('./features/auth/login.page').then((m) => m.LoginPageComponent),
      },
      {
        path: 'signup',
        canActivate: [guestOnlyGuard],
        loadComponent: () =>
          import('./features/auth/signup.page').then((m) => m.SignupPageComponent),
      },
      {
        path: 'legal/terms',
        loadComponent: () =>
          import('./features/legal/terms.page').then((m) => m.TermsPageComponent),
      },
      {
        path: 'legal/privacy',
        loadComponent: () =>
          import('./features/legal/privacy.page').then((m) => m.PrivacyPageComponent),
      },
      {
        path: 'events/:storeSlug/:eventSlug',
        loadComponent: () =>
          import('./features/public-event/public-event.page').then(
            (m) => m.PublicEventPageComponent,
          ),
      },
      {
        path: 'events/:storeSlug/:eventSlug/register',
        loadComponent: () =>
          import('./features/public-event/register.page').then(
            (m) => m.RegisterPageComponent,
          ),
      },
      {
        path: 'r/:id',
        loadComponent: () =>
          import('./features/player/registration-detail.page').then(
            (m) => m.RegistrationDetailPageComponent,
          ),
      },
      {
        path: 'me',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/player/my-registrations.page').then(
            (m) => m.MyRegistrationsPageComponent,
          ),
      },
      {
        path: 'me/profile',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/player/profile.page').then((m) => m.ProfilePageComponent),
      },
      {
        path: 'payments/checkout/:paymentId',
        loadComponent: () =>
          import('./features/payments/checkout-stub.page').then(
            (m) => m.CheckoutStubPageComponent,
          ),
      },
      {
        path: 'payments/return/:paymentId',
        loadComponent: () =>
          import('./features/payments/payment-return.page').then(
            (m) => m.PaymentReturnPageComponent,
          ),
      },
    ],
  },
  {
    path: 'app',
    component: StoreLayoutComponent,
    canActivate: [storeAdminGuard],
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./features/store-dashboard/dashboard.page').then(
            (m) => m.DashboardPageComponent,
          ),
      },
      {
        path: 'events',
        loadComponent: () =>
          import('./features/event-management/event-list.page').then(
            (m) => m.EventListPageComponent,
          ),
      },
      {
        path: 'events/new',
        loadComponent: () =>
          import('./features/event-management/event-form.page').then(
            (m) => m.EventFormPageComponent,
          ),
      },
      {
        path: 'events/:eventId',
        loadComponent: () =>
          import('./features/event-management/event-detail.page').then(
            (m) => m.EventDetailPageComponent,
          ),
      },
      {
        path: 'events/:eventId/edit',
        loadComponent: () =>
          import('./features/event-management/event-form.page').then(
            (m) => m.EventFormPageComponent,
          ),
      },
      {
        path: 'events/:eventId/share',
        loadComponent: () =>
          import('./features/event-management/event-share.page').then(
            (m) => m.EventSharePageComponent,
          ),
      },
      {
        path: 'events/:eventId/participants',
        loadComponent: () =>
          import('./features/participants/participants.page').then(
            (m) => m.ParticipantsPageComponent,
          ),
      },
      {
        path: 'settings',
        loadComponent: () =>
          import('./features/store-dashboard/store-settings.page').then(
            (m) => m.StoreSettingsPageComponent,
          ),
      },
    ],
  },
  { path: '**', redirectTo: '' },
];
