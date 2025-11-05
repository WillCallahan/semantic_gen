# Selenium Demo

1. Run `flutter pub get` inside `example/` and the package root.
2. Enable the semantics DOM overlay when the app launches:

   ```js
   const glass = document.querySelector('flt-glass-pane');
   if (glass && glass.shadowRoot) {
     const toggle = glass.shadowRoot.querySelector('flt-semantics-placeholder');
     toggle?.click();
   }
   ```

3. Locate widgets by their semantics label:

   ```js
   const heading = driver.findElement(By.css('[aria-label="test:auto:Text"]'));
   const submit = driver.findElement(By.css('[aria-label="test:auth:LoginButton"]'));
   const explicit = driver.findElement(By.css('[aria-label="test:auth:submit"]'));
   ```

4. Wrap your Selenium commands in test assertions to automate the workflow end-to-end.
