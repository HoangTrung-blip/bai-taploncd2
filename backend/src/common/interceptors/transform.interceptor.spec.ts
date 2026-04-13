import { TransformInterceptor } from './transform.interceptor';
import { CallHandler, ExecutionContext } from '@nestjs/common';
import { of } from 'rxjs';

describe('TransformInterceptor', () => {
  let interceptor: TransformInterceptor<any>;

  beforeEach(() => {
    interceptor = new TransformInterceptor();
  });

  it('bọc dữ liệu trả về trong cấu trúc ApiResponse', (done) => {
    const mockData = { id: 1, name: 'Test' };
    const mockExecutionContext = {} as ExecutionContext;
    const mockCallHandler: CallHandler = {
      handle: () => of(mockData),
    };

    interceptor
      .intercept(mockExecutionContext, mockCallHandler)
      .subscribe((result) => {
        expect(result.success).toBe(true);
        expect(result.data).toEqual(mockData);
        expect(result.timestamp).toBeDefined();
        expect(typeof result.timestamp).toBe('string');
        done();
      });
  });

  it('trả về success=true khi dữ liệu là mảng rỗng', (done) => {
    const mockExecutionContext = {} as ExecutionContext;
    const mockCallHandler: CallHandler = {
      handle: () => of([]),
    };

    interceptor
      .intercept(mockExecutionContext, mockCallHandler)
      .subscribe((result) => {
        expect(result.success).toBe(true);
        expect(result.data).toEqual([]);
        done();
      });
  });

  it('trả về success=true khi dữ liệu là null', (done) => {
    const mockExecutionContext = {} as ExecutionContext;
    const mockCallHandler: CallHandler = {
      handle: () => of(null),
    };

    interceptor
      .intercept(mockExecutionContext, mockCallHandler)
      .subscribe((result) => {
        expect(result.success).toBe(true);
        expect(result.data).toBeNull();
        done();
      });
  });
});
