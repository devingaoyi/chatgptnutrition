import type { NextFunction, Request, Response } from "express";

export class ApiError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
  ) {
    super(message);
  }
}

export function asyncHandler(
  handler: (req: Request, res: Response, next: NextFunction) => Promise<unknown>,
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(handler(req, res, next)).catch(next);
  };
}

export function errorHandler(
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
) {
  if (error instanceof ApiError) {
    return res.status(error.status).json({
      error: {
        code: error.code,
        message: error.message,
      },
    });
  }

  if (error && typeof error === "object" && "name" in error && error.name === "ZodError") {
    return res.status(400).json({
      error: {
        code: "validation_error",
        message: "Request payload is invalid.",
        details: error,
      },
    });
  }

  console.error(error);
  return res.status(500).json({
    error: {
      code: "internal_error",
      message: "Internal server error.",
    },
  });
}
