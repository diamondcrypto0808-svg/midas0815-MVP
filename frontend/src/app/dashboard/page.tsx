'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { apiClient, APIError } from '@/lib/api/client'
import { toast } from 'sonner'

interface DashboardData {
  users: {
    total: number
    new_today: number
    new_this_week: number
    new_this_month: number
  }
  posts: {
    total: number
    today: number
    this_week: number
    this_month: number
  }
  matches: {
    total: number
    today: number
    this_week: number
    this_month: number
  }
  contents: {
    total: number
    published: number
    draft: number
  }
}

export default function DashboardPage() {
  const router = useRouter()
  const [data, setData] = useState<DashboardData | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('access_token')
    if (!token) {
      router.push('/login')
      return
    }

    fetchDashboardData(token)
  }, [router])

  const fetchDashboardData = async (token: string) => {
    try {
      const response = await apiClient<DashboardData>('/api/v1/analytics/dashboard', {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      setData(response)
    } catch (error) {
      if (error instanceof APIError) {
        if (error.status === 401) {
          toast.error('セッションが期限切れです。再度ログインしてください。')
          router.push('/login')
        } else if (error.status === 403) {
          toast.error('ダッシュボードへのアクセス権限がありません')
        } else {
          toast.error(error.message)
        }
      }
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = () => {
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    toast.success('ログアウトしました')
    router.push('/login')
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">読み込み中...</p>
        </div>
      </div>
    )
  }

  if (!data) {
    return null
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">ダッシュボード</h1>
          <button
            onClick={handleLogout}
            className="px-4 py-2 text-sm font-medium text-gray-700 hover:text-gray-900"
          >
            ログアウト
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {/* Users Card */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500 mb-2">ユーザー</h3>
            <p className="text-3xl font-bold text-gray-900">{data.users.total}</p>
            <div className="mt-4 space-y-1 text-sm text-gray-600">
              <p>今日: {data.users.new_today}人</p>
              <p>今週: {data.users.new_this_week}人</p>
              <p>今月: {data.users.new_this_month}人</p>
            </div>
          </div>

          {/* Posts Card */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500 mb-2">投稿</h3>
            <p className="text-3xl font-bold text-gray-900">{data.posts.total}</p>
            <div className="mt-4 space-y-1 text-sm text-gray-600">
              <p>今日: {data.posts.today}件</p>
              <p>今週: {data.posts.this_week}件</p>
              <p>今月: {data.posts.this_month}件</p>
            </div>
          </div>

          {/* Matches Card */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500 mb-2">マッチ</h3>
            <p className="text-3xl font-bold text-gray-900">{data.matches.total}</p>
            <div className="mt-4 space-y-1 text-sm text-gray-600">
              <p>今日: {data.matches.today}件</p>
              <p>今週: {data.matches.this_week}件</p>
              <p>今月: {data.matches.this_month}件</p>
            </div>
          </div>

          {/* Contents Card */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500 mb-2">コンテンツ</h3>
            <p className="text-3xl font-bold text-gray-900">{data.contents.total}</p>
            <div className="mt-4 space-y-1 text-sm text-gray-600">
              <p>公開: {data.contents.published}件</p>
              <p>下書き: {data.contents.draft}件</p>
            </div>
          </div>
        </div>

        {/* Quick Links */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">クイックリンク</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <a
              href="/timeline"
              className="p-4 border border-gray-200 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors text-center"
            >
              <p className="font-medium text-gray-900">タイムライン</p>
            </a>
            <a
              href="/matching"
              className="p-4 border border-gray-200 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors text-center"
            >
              <p className="font-medium text-gray-900">マッチング</p>
            </a>
            <a
              href="/contents"
              className="p-4 border border-gray-200 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors text-center"
            >
              <p className="font-medium text-gray-900">コンテンツ</p>
            </a>
            <a
              href="/profile"
              className="p-4 border border-gray-200 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors text-center"
            >
              <p className="font-medium text-gray-900">プロフィール</p>
            </a>
          </div>
        </div>
      </main>
    </div>
  )
}
