
Fsek::Application.routes.draw do

  # Resources on the page
  #get 'kurslankar' => 'static_pages#kurslankar'
  get 'libo' => 'static_pages#libo', as: :libo
  get 'kalender' => 'events#calendar',as: :kalender
  get '/nollning', to: redirect('http://nollning.fsektionen.se'), as: :nollning
  get '/vecktorn', to: redirect('http://old.fsektionen.se/vecktorn/signup.php'), as: :vecktorn_signup
  
  get 'om' => 'static_pages#om', as: :om
  get 'engagemang' => 'static_pages#utskott', as: :engagemang
  #get 'multimedia' => 'static_pages#lankar', as: :multimedia #Ev. efterfrågad av vårt kära Sanningsministerium!
  #get 'lankar' => 'static_pages#lankar', as: :lankar
  
  get 'organisation' => 'static_pages#utskott', as: :organisation
  #get 'erbjudande' => 'static_pages#om', as: :erbjudande
  
  # User-related routes
  devise_for :users, skip: [:sessions, :registrations], controllers: {registrations: "registrations"}
  devise_scope :user do
    #registration
    get     'avbryt_reg'  => 'registrations#cancel', as: :cancel_user_registration
    post    'anvandare/skapa'        => 'registrations#create', as: :user_registration 
    get     'anvandare/registrera'     => 'registrations#new',    as: :new_user_registration
    patch   'anvandare/redigera/:id'        => 'users#update_password', as: :update_user_registration 
    get     'anvandare/redigera'   => 'registrations#edit',   as: :edit_user_registration
    delete  'anvandare/ta_bort/:id' => 'users#destroy', :as => :admin_destroy_user

    #sessions
    get     'logga_in'       => 'devise/sessions#new',         as: :new_user_session
    post    'logga_in'       => 'devise/sessions#create',      as: :user_session   
    delete  'logga_ut'      => 'devise/sessions#destroy',     as: :destroy_user_session
    patch   'anvandare/redigera' => 'users#change_role',  as: :change_role
  end
  
  get 'anvandare' => 'users#index', as: :users
  

  # Scope to change urls to swedish
  scope path_names: { new: 'ny',edit: 'redigera' } do
    scope :hilbertcafe do

      # Hilbert Café admin
      namespace :admin do
        resources :cafe_works, path: :jobb, controller: :cafe_works,except: :index do
          patch :remove_worker, path: :jobbare, on: :member
        end
        get '/setup', controller: :cafe_works,action: :setup, as: :setup_cafe
        post '/setup/skapa', controller: :cafe_works, action: :setup_create, as: :setup_cafe_create
        get '', controller: :cafe_works, action: :main, as: :hilbert        
      end

      # Hilbert Café for users
      resources :cafe_works, path: :jobb, only: [:show,:update] do
        patch :remove_worker, path: :inte_jobba, on: :member
        patch :authorize, path: :auktorisera,  on: :member
      end
      # Normal routes
      get '', controller: :cafe_works, action: :main, as: :hilbert
      get '/nyckelpiga', controller: :cafe_works, action: :nyckelpiga
      #get '/tavling', controller: :cafe_works, action: :tavling, as: :cafe_tavling         
    end

    # A scope to put car-associated things under /bil
    # /d.wessman
    scope :bil do
      resources :rents, path: :bokning do
        patch :update_status, on: :member
      end     
      get :forman, controller: :rents, action: :forman
      get '', controller: :rents, action: :main, as: :bil      
    end

    resources :notices, path: :notiser do
      post :display, path: :visa, on: :member
      get :image, path: :bild, on: :member
    end
    resources :menus,path: :meny, except: :show

    resources :posts,path: :poster, only: :index

    resources :councils, path: :utskott do
      resources :posts, path: :poster do
        patch :remove_profile, on: :member
        patch :add_profile_username, on: :member
      end
      resource :page, path: :sida do
        resources :page_elements, path: :element, on: :member
      end
    end

    resources :faqs, path: :faq do
      #resource :categories, path: :kategori, on: :collection
    end

    resources :contacts, path: :kontakt do
      post :mail, on: :member
    end

    resources :profiles, path: :profil do
      patch :remove_post, on: :member
      get :avatar, on: :member
    end

    resources :events do      
      get :export, on: :collection
    end

    resources :notices, path: :notiser

    resources :work_posts, path: :jobbportal, except: :show

    resources :news ,path:  :nyheter

    resources :documents, path: :dokument

    resources :elections, path: :val do
      get :nominate, path: :nominera, on: :collection
      post :nominate,action: :create_nomination,path: :nominera, on: :collection
      get :candidate, path: :kandidera, on: :collection
      post :candidate,action: :create_candidate,path: :kandidera, on: :collection

      resources :nominations, path: :nomineringar, except: [:new, :update,:create]
      resources :candidates, path: :kandidaturer, except: [:new, :update] 
    end

    resources :categories, path: :kategorier

    resources :albums, path: :galleri do
      get :upload_images, path: :ladda_upp, on: :member
      post :upload_images, path: :ladda_upp, on: :member
      delete :destroy_images, path: :ta_bort_bilder, on: :member

      resources :images, path: :bilder, except: [:new] do
        get :display, path: :visa, on: :member
        get :show_full, path: :visa_stor, on: :member
      end 
    end
  end

  TheRoleManagementPanel::Routes.mixin(self)
   
  root 'static_pages#index'


end
