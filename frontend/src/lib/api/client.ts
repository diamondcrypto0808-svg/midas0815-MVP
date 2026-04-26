const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'

export class APIError extends Error {
  constructor(
    public code: string,
    public message: string,
    public status: number,
    public details?: any
  ) {
    super(message)
    this.name = 'APIError'
  }
}

export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const url = `${API_URL}${endpoint}`

  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      credentials: 'include',
    })

    if (!response.ok) {
      const errorData = await response.json()
      throw new APIError(
        errorData.error?.code || 'UNKNOWN_ERROR',
        errorData.error?.message || 'エラーが発生しました',
        response.status,
        errorData.error?.details
      )
    }

    const data = await response.json()
    return data.data as T
  } catch (error) {
    if (error instanceof APIError) {
      throw error
    }

    if (error instanceof TypeError && error.message === 'Failed to fetch') {
      throw new APIError(
        'NETWORK_ERROR',
        'ネットワークエラーが発生しました。インターネット接続を確認してください。',
        0
      )
    }

    throw new APIError(
      'UNKNOWN_ERROR',
      '予期しないエラーが発生しました',
      0
    )
  }
}
