require 'debug'
require "awesome_print"

class App < Sinatra::Base
    register Sinatra::Reloader

    def db
      return @db if @db

      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    get '/todos/new' do
    @todos = db.execute('SELECT * FROM todos ORDER BY name')

    erb(:"todos/new")
  end

    get '/' do
      @todos = db.execute('SELECT * FROM todos')
      erb(:'todos/index')
    end

    get '/todos' do
      @todos = db.execute('SELECT * FROM todos')
      erb(:'todos/index')
    end

    get '/todos/:id' do
      @todo = db.execute('SELECT * FROM todos WHERE id = ?', params[:id]).first
      erb(:'todos/show')
    end

  post '/todos/:id/delete' do |id|
    db.execute('DELETE FROM todos WHERE id = ?', id)
    redirect('/')
  end


  post '/todos/:id/edit' do |id|
    completed_id = params['completed_id'].to_s.empty? ? nil : params['completed_id']
    db.execute(
      'UPDATE todos SET name = ?, description = ?, completed = ? WHERE id = ?',
      [
        params['todo_name'],
        params['todo_description'],
        params['todo_completed'] == '1' ? 1 : 0,
        id
      ]
    )
    redirect('/')
  end

  get '/todos/:id/edit' do |id|
    @todo = db.execute('SELECT * FROM todos WHERE id = ?', id).first
    halt 404 unless @todo

    erb(:'todos/edit')
  end

  post '/todos/new' do
    db.execute(
      'INSERT INTO todos (name, description, completed) VALUES (?, ?, ?)',
      [
        params['todo_name'],
        params['todo_description'],
        params['todo_completed'] == '1' ? 1 : 0
      ]
    )
    redirect('/')
  end
end