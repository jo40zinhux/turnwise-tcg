import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { DomainError } from '../domain-error';

@Catch()
export class DomainExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const response = host.switchToHttp().getResponse<Response>();

    if (exception instanceof DomainError) {
      return response.status(exception.status).json({
        message: exception.message,
        code: exception.code,
      });
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse();
      const raw =
        typeof body === 'string'
          ? body
          : (body as { message?: string | string[]; code?: string }).message;
      const message = Array.isArray(raw) ? raw.join(' ') : raw;
      const code =
        typeof body === 'object' && body && 'code' in body
          ? String((body as { code?: string }).code)
          : 'HTTP_ERROR';
      return response.status(status).json({
        message: message || exception.message,
        code,
      });
    }

    console.error(exception);
    return response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      message: 'Erro interno.',
      code: 'INTERNAL',
    });
  }
}
