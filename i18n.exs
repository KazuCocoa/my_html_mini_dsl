defmodule Translator do
  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :locales, accumulate: true, persist: false

      import unquote(__MODULE__), only: [locale: 2]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :locales))
  end

  defmacro locale(name, mappings) do
    quote bind_quoted: [name: name, mappings: mappings] do
      @locales {name, mappings}
    end
  end

  def compile(translations) do
    translations_ast = for {locale, mappings} <- translations do
      deftranslations(locale, "", mappings)
    end

    final_ast = quote do
      def t(locale, path, bindings \\ [])
      unquote(translations_ast)
      def t(_locale, _path, _bindings), do: {:error, :no_translation}
    end

    IO.puts Macro.to_string(final_ast)
    final_ast
  end

  defp deftranslations(locales, current_path, mappings) do
    for {key, val} <- mappings do
      path = append_path(current_path, key)
      if Keyword.keyword?(val) do
        deftranslations(locales, path, val)
      else
        quote do
          def t(unquote(locales), unquote(path), bindings) do
            unquote(integraters(val))
          end
        end
      end
    end
  end

  defp integraters(string) do
    string # TBD
  end

  defp append_path("", next), do: to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"

end

defmodule I18n do
  use Translator

  locale "en",
    flash: [
      hello: "Hello %{first} %{last}",
      bye: "Bye, %{name}"
    ],
    users: [
      title: "Users",
    ]

  locale "ja",
    flash: [
      hello: "こんにちは %{first} %{last}",
      bye: "ばいばい, %{name}"
    ],
    users: [
      title: "ユーザ",
    ]

end


defmodule Sample do
  import I18n

  def run do
    IO.inspect I18n.t("en", "flash.hello", first: "Chris", last: "McCord")
    IO.inspect I18n.t("ja", "flash.hello", first: "Chris", last: "McCord")

    IO.inspect I18n.t("en", "users.title")
    IO.inspect I18n.t("ja", "users.title")
  end
end
